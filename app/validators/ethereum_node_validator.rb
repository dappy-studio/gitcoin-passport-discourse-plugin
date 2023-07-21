# frozen_string_literal: true
require 'net/http'
require 'json'

class ::EthereumNodeUrlValidator
  def self.valid_url?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def self.valid_ethereum_node?(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = { jsonrpc: "2.0", id: 1, method: "web3_clientVersion", params: [] }.to_json

    response = http.request(request)
    result = JSON.parse(response.body)
    puts result
    return result['result'] && result['jsonrpc'] == '2.0'
  rescue
    false
  end

  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(value)
    puts "valid_value? #{value}"
    !!(EthereumNodeUrlValidator.valid_url?(value) && EthereumNodeUrlValidator.valid_ethereum_node?(value))
  end

  def error_message
    I18n.t("site_settings.errors.ethereum_node_url_invalid")
  end
end

