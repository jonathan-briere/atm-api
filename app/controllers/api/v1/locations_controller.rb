# frozen_string_literal: true

module Api
  module V1
    class LocationsController < ApplicationController
      def index
        render json: collection
      end

      def show
        response = Geo::Location.new.find_by(ip: params[:id])

        if (200..209).include? response[:status]
          render json: response[:body]
        else
          render json: { error: response[:errors] }, status: response[:status]
        end
      end

      private

        def collection
          ip_addresses = cached_ip_addresses

          if params[:country].present?
            ip_addresses.select! do |address|
              address[:country].downcase.include? params[:country].downcase
            end
          end

          ip_addresses
        end

        def cached_ip_addresses
          keys = Rails.cache.instance_variable_get(:@data).keys

          keys.map do |key|
            Rails.cache.read(key)[:body].with_indifferent_access
          end
        end
    end
  end
end
