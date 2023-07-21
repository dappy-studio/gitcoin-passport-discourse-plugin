module Eth
# Provides ENS specific functionality
  # ref: https://ens.domains
  module Ens
    # Provides EIP-2304 / SLIP-44 cointypes to resolve ENS addresses.
    # ref: https://eips.ethereum.org/EIPS/eip-2304
    module CoinType
      extend self

      # ENS coin type for Bitcoin.
      BITCOIN = 0.freeze

      # ENS coin type for Litecoin.
      LITECOIN = 2.freeze

      # ENS coin type for Dogecoin.
      DOGECOIN = 3.freeze

      # ENS coin type for Ethereum.
      ETHEREUM = 60.freeze

      # ENS coin type for Ethereum Classic.
      ETHEREUM_CLASSIC = 61.freeze

      # ENS coin type for Rootstock.
      ROOTSTOCK = 137.freeze

      # ENS coin type for Bitcoin Cash.
      BITCOIN_CASH = 145.freeze

      # ENS coin type for Binance.
      BINANCE = 714.freeze
    end
  end
end
