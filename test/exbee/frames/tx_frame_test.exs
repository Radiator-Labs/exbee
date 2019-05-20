defmodule Exbee.TxFrameTest do
  use Exbee.TestCase

  alias Exbee.{EncodableFrame, TxFrame}

  test "encodes integer payloads" do
    tx_frame = %TxFrame{mac_addr: "0000000000000001", network_addr: 0x02, payload: 1}
    expected = <<0x10, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1, 0x0, 0x2, 0x0, 0x0, 0x1>>
    assert EncodableFrame.encode(tx_frame) == expected
  end

  test "encodes binary payloads" do
    tx_frame = %TxFrame{mac_addr: "0000000000000001", network_addr: 0x02, payload: <<0x01>>}
    expected = <<0x10, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1, 0x0, 0x2, 0x0, 0x0, 0x1>>
    assert EncodableFrame.encode(tx_frame) == expected
  end
end
