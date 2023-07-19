# frozen_string_literal: true

  class EthAddressValidator
    def initialize(opts = {})
      @opts = opts
    end

    def valid_value?(value)
      ethereum_address_regex = /^0x[a-fA-F0-9]{40}$/
      return !!(value =~ ethereum_address_regex)
    end

    def error_message
      I18n.t("site_settings.errors.chat_default_channel")
    end
  end

