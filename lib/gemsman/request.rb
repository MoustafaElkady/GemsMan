require 'net/http'
require "open-uri"

module Gemsman
  module Request
    # API END-POINT
    DEFAULT_HOST = 'https://gemsman-api.herokuapp.com'

    # POST Method
    def post(path, data = {})
      request(:post, path, data, content_type = 'application/x-www-form-urlencoded')
    end

    def request(method, path, data, content_type)
      # concat host + api endpoint then parse it as URI
      uri = URI.parse [DEFAULT_HOST, path].join

      request_class = Net::HTTP.const_get method.to_s.capitalize
      request = request_class.new uri.request_uri
      request.content_type = content_type

      # set data according to the content_type
      case content_type
        when 'application/x-www-form-urlencoded'
          request.form_data = data if [:post, :put].include? method
        when 'application/octet-stream'
          request.body = data
          request.content_length = data.size
      end

      # Open the connection
      @connection = Net::HTTP.new uri.host, uri.port

      # if it https use verify_mode
      if uri.scheme == 'https'
        require 'net/https'
        @connection.use_ssl = true
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      # Start the connection
      @connection.start
      response = @connection.request request
      response.body
    end
  end

end
