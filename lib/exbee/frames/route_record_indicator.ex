defmodule Exbee.RouteRecordIndicator do
  @moduledoc """
  The route record indicator is received whenever a device sends a Zigbee route record command. 
  This is used with many-to-one routing to create source routes for devices in a network. 

  Possible `:option` values:

    * `0x01` - Packet acknowledged
    * `0x02` - Packet was a broadcast
  """

  @type t :: %__MODULE__{
          mac_addr: binary,
          network_addr: integer,
          options: integer,
          payload: binary
        }
  defstruct [
      :mac_addr,
      :network_addr,
      :options,
      :payload
  ]

  defimpl Exbee.DecodableFrame do
    def decode(frame, encoded_binary) do
      case encoded_binary do
        <<0xA1, mac_addr::binary-size(8), network_addr::16, options::8, payload::binary>> ->
          decoded_frame = %{
            frame
            | mac_addr: mac_addr |> Base.encode16(),
              network_addr: network_addr,
              options: options,
              payload: payload
          }

          {:ok, decoded_frame}

        _ ->
          {:error, :invalid_binary}
      end
    end
  end
end
