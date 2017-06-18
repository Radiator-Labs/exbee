defmodule Exbee.GenericFrame do
  defstruct [:type, :payload]

  defimpl Exbee.FrameDecoder do
    def decode(frame, <<type::8, payload::binary>>) do
      {:ok, %{frame | type: type, payload: payload}}
    end
  end

  defimpl Exbee.FrameEncoder do
    def encode(%{type: type, payload: payload}) do
      <<type, payload::binary>>
    end
  end
end