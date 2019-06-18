defmodule Exbee.CreateSourceRoute do
  @moduledoc """
  Frame type: 0x21
  https://www.digi.com/resources/documentation/digidocs/PDFs/90000976.pdf#page=123
  
  This frame creates a source route in the module. A source route specifies the complete route a packet should 
  traverse to get from source to destination. Source routing should be used with many-to-one routing for best results.
  In contrast to many-to-one routing that establishes routing paths from many devices to one data collector, 
  source routing allows the collector to store and specify routes for many remotes. 
  To use source routing on a network, many-to-one routes must first be established on the network from remote nodes 
  to the central data collector.

  Using Source Routing with XBee Serial API

  In order to use source routing with the XBee Serial API, the following steps must be taken:

    To store source routes for remote nodes:
        Remote nodes must first send a unicast transmission to the central collector
        Upon receipt of a unicast, the XBee will emit a route record indicator frame (XBee API frame type 0xA1)
        The information from the route record frame must be interpreted and stored by your application for later use
    To transmit using a source route:
        Configure the XBee with the source route using Create Source Route (XBee API frame type 0x21)
        Transmit request (XBee API frame types 0x10 or 0x11)
        Interpretation of the Transmit Status (XBee API frame 0x8B)


    `:id` (Frame ID) value should always be set to `0x00`
    `:option` value should always be set to `0x00`
  """

  @type t :: %__MODULE__{
    id: integer,
    mac_addr: binary,
    network_addr: integer,
    options: integer,
    number_of_addresses: integer,
    payload: binary
  }
defstruct id: 0x00,
      mac_addr: "FFFFFFFFFFFFFFFF",
      network_addr: 0xFFFE,
      options: 0x00,
      number_of_addresses: 0x01, #do not include source and destination
      payload: nil

defimpl Exbee.EncodableFrame do
alias Exbee.Util

def encode(%{
    id: id,
    mac_addr: mac_addr,
    network_addr: network_addr,
    options: options,
    number_of_addresses: number_of_addresses,
    payload: payload
  }) do
<<0x21, id::8>> <>
  Base.decode16!(mac_addr) <>
  <<network_addr::16, options::8, number_of_addresses::8, Util.to_binary(payload)::binary>>
end
end
end
