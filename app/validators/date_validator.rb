# frozen_string_literal: true

class ::DateValidator
  def self.valid_date_string?(date_string)
    Date.parse(date_string)
    true
  rescue ArgumentError
    false
  end

  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(value)
    !!(value == "" || DateValidator.valid_date_string?(value))
  end

  def error_message
    I18n.t("site_settings.errors.date_invalid")
  end
end

