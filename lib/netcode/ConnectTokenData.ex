defmodule Netcode.ConnectTokenData do
  use Tonic, optimize: true

  endian :little

  uint64 :client_id
  uint32 :num_server_addresses
  repeat :server_address, verify_num_servers(get(:num_server_addresses)) do
    uint8 :address_type
    on get(:address_type) do
      # value of 1 = IPv4 address, 2 = IPv6 address.
      1 ->
        # for a given IPv4 address: a.b.c.d:port
        uint8 :a
        uint8 :b
        uint8 :c
        uint8 :d
        uint16 :port
      2 ->
        # for a given IPv6 address: [a:b:c:d:e:f:g:h]:port
        uint16 :a
        uint16 :b
        uint16 :c
        uint16 :d
        uint16 :e
        uint16 :f
        uint16 :g
        uint16 :h
        uint16 :port
    end
  end
  uint8 :client_to_server_key, length: 32
  uint8 :server_to_client_key, length: 32
  uint8 :user_data, length: 256 # user defined data specific to this protocol id
  repeat :zero_pad do
    repeat :uint8
  end

  @doc """
  Verify number of servers is [1,32].
  """
  def verify_num_servers(num) do
    cond do
      num in 1..32 -> num
      true -> exit "Invalid number of servers."
    end
  end
end
