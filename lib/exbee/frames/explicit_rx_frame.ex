defmodule Exbee.ExplicitRxFrame do
  @moduledoc """
  Similar to the `Exbee.RxFrame` but includes additional attributes from the sender.

  A device configured with the explicit API Rx Indicator (`AO = 1`) will return this frame when it
  receives an RF packet.
  """

  @type t :: %__MODULE__{
          mac_addr: binary,
          network_addr: integer,
          source: integer,
          endpoint: integer,
          cluster_id: integer,
          profile_id: integer,
          options: integer,
          payload: binary
        }
  defstruct [
    :mac_addr,
    :network_addr,
    :source,
    :endpoint,
    :cluster_id,
    :profile_id,
    :options,
    :payload
  ]

  defimpl Exbee.DecodableFrame do
    def decode(frame, encoded_binary) do
      case encoded_binary do
        <<0x91, mac_addr::binary-size(8), network_addr::16, source::8, endpoint::8, cluster_id::16,
          profile_id::16, options::8, payload::binary>> ->
          decoded_frame = %{
            frame
            | mac_addr: mac_addr |> Base.encode16(),
              network_addr: network_addr,
              source: source,
              endpoint: endpoint,
              cluster_id: cluster_id,
              profile_id: profile_id,
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
