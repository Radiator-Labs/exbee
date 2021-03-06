defmodule Exbee.RxFrame do
  @moduledoc """
  Received when a device reads a transmission from a remote node.

  A device configured with the standard API Rx Indicator (`AO = 0`) will return this frame when it
  receives an RF packet.
  """

  @type t :: %__MODULE__{mac_addr: binary, network_addr: integer, type: integer, payload: binary}
  defstruct [:mac_addr, :network_addr, :type, :payload]

  defimpl Exbee.DecodableFrame do
    def decode(frame, encoded_binary) do
      case encoded_binary do
        <<0x90, mac_addr::binary-size(8), network_addr::16, type::8, payload::binary>> ->
          decoded_frame = %{
            frame
            | mac_addr: Base.encode16(mac_addr),
              network_addr: network_addr,
              type: type,
              payload: payload
          }

          {:ok, decoded_frame}

        _ ->
          {:error, :invalid_binary}
      end
    end
  end
end
