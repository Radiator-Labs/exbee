defmodule Exbee.Message do
  @moduledoc """
  Converts between binary messages and frames.
  """

  alias Exbee.{EncodableFrame, DecodableFrame}

  require Logger

  @separator <<0x7E>>

  @decodable_frames %{
    0x88 => Exbee.ATCommandResultFrame,
    0x8A => Exbee.DeviceStatusFrame,
    0x8B => Exbee.TxResultFrame,
    0x90 => Exbee.RxFrame,
    0x91 => Exbee.ExplicitRxFrame,
    0x92 => Exbee.RxSampleReadFrame,
    0x94 => Exbee.RxSensorReadFrame,
    0x97 => Exbee.RemoteATCommandResultFrame
  }

  @doc """
  Decodes a binary message into frames using the `Exbee.DecodableFrame` protocol.

  Messages can arrive incomplete, so this returns a buffer of any partial messages. The caller
  should return this buffer prepended to the next message.

  Frames with invalid checksums will be dropped.
  """
  @spec parse(binary) :: {binary, [DecodableFrame.t()]}
  def parse(data) do
    do_parse(data, [])
  end

  @doc """
  Encodes a frame into a binary message using the `Exbee.EncodableFrame` protocol.

  It applies the separator, length, and checksum bytes.
  """
  @spec build(EncodableFrame.t()) :: binary
  def build(frame) do
    encoded_frame = EncodableFrame.encode(frame)

    <<@separator, byte_size(encoded_frame)::16, encoded_frame::binary,
      calculate_checksum(encoded_frame)>>
  end

  defp do_parse(data, frames) do
    with [_, post_separator] <- :binary.split(data, @separator) do
      case post_separator do
        <<length::16, encoded_frame::binary-size(length), checksum::8, remainder::binary>> ->
          do_parse(remainder, apply_frame(frames, encoded_frame, checksum))

        _ ->
          {@separator <> post_separator, frames}
      end
    else
      [_] -> {<<>>, frames}
    end
  end

  defp apply_frame(frames, <<frame_type::8, _rest::binary>> = encoded_frame, checksum) do
    frame_struct = Map.get(@decodable_frames, frame_type, Exbee.GenericFrame) |> struct()

    with {:ok, _} <- validate_checksum(encoded_frame, checksum),
         {:ok, decoded_frame} <- DecodableFrame.decode(frame_struct, encoded_frame) do
      [decoded_frame | frames]
    else
      {:error, reason} ->
        Logger.warn(reason)
        frames
    end
  end

  defp validate_checksum(encoded_frame, checksum) do
    calculated = calculate_checksum(encoded_frame)

    if calculated == checksum do
      {:ok, calculated}
    else
      details = "Should equal #{inspect(calculated)}, but got #{inspect(checksum)}"
      {:error, "Invalid checksum for frame #{inspect(encoded_frame)}. (#{details})"}
    end
  end

  defp calculate_checksum(encoded_frame),
    do:
      0xFF - (encoded_frame |> :erlang.binary_to_list() |> Enum.reduce(0, &Kernel.+/2) |> rem(256))
end
