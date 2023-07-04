# frozen_string_literal: true

module Geo
  class Base
    BASE_URL = 'https://get.geojs.io/v1/ip/'

    def initialize(url)
      @url = BASE_URL + url
    end

    def request(body: {}, method: :get)
      validate_response do
        HTTParty.send(method, @url, body: body, headers: headers)
      end
    end

    private

      def validate_response
        response = yield
        code = response.code.to_i
        body = response.body

        if successful?(code)
          format_response(response)
        else
          { status: code, errors: body }
        end
      end

      def successful?(code)
        (200..209).cover?(code)
      end

      def format_response(response)
        {
          headers: response.headers,
          status: response.code,
          body: JSON.parse(response.body)
        }
      end

      def headers
        {
          'Content-Type': 'application/json'
        }
      end
  end
end
