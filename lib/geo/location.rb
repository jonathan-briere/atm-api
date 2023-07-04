# frozen_string_literal: true

module Geo
  class Location < Base
    BASE_URL = 'geo'

    def initialize
      super(BASE_URL)
    end

    def find_by(ip:)
      @url += "/#{ip}.json"

      Rails.cache.fetch(ip) do
        request
      end
    end
  end
end
