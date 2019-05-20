defmodule Exbee.RemoteATCommandResultFrame do
  @moduledoc """
  Received in response to an `Exbee.RemoteATCommandFrame`.

  Some commands end back multiple frames; for example, the `ND` command.
  """

  @type t :: %__MODULE__{
          id: integer,
          mac_addr: binary,
          network_addr: integer,
          command: String.t(),
          status: atom,
          value: binary
        }
  defstruct [:id, :mac_addr, :network_addr, :command, :status, :value]

  defimpl Exbee.DecodableFrame do
    @statuses %{
      0x00 => :ok,
      0x01 => :error,
      0x02 => :invalid_command,
      0x03 => :invalid_parameter,
      0x04 => :transmition_failure
    }

    def decode(frame, encoded_binary) do
      case encoded_binary do
        <<0x97, id::8, mac_addr::binary-size(8), network_addr::16, command::bitstring-size(16),
          status::8, value::binary>> ->
          decoded_frame = %{
            frame
            | id: id,
              mac_addr: Base.encode16(mac_addr),
              network_addr: network_addr,
              command: command,
              status: @statuses[status],
              value: value
          }

          {:ok, decoded_frame}

        _ ->
          {:error, :invalid_binary}
      end
    end
  end
end
