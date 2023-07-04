# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LocationsController, type: :controller do
  describe '#index' do
    context 'when cache has no ip_addresses' do
      it 'will return empty response' do
        get :index

        expect(JSON.parse(response.body)).to be_empty
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when cache has ip_addresses found' do
      let!(:ip_address) do
        Rails.cache.fetch('8.8.8.8') do
          { body:
            {
              organization_name: 'GOOGLE',
              accuracy: 1000,
              asn: 15_169,
              organization: 'AS15169 GOOGLE',
              timezone: 'America/Chicago',
              longitude: '-97.822',
              country_code3: 'USA',
              area_code: '0',
              ip: '8.8.8.8',
              country: 'United States',
              continent_code: 'NA',
              country_code: 'US',
              latitude: '37.751'
            },
            status: 200 }
        end
      end

      context 'when no params passed' do
        it 'will retun all cache addresses' do
          get :index

          ip = JSON.parse(response.body).first['ip']
          expect(ip).to eq(ip_address[:body][:ip])
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when wrong param key passed' do
        it 'will return all cached addresses' do
          get :index, params: { loaction: 'US' }

          ip = JSON.parse(response.body).first['ip']
          expect(ip).to eq(ip_address[:body][:ip])
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when correct params passed' do
        context 'when country present in cached ip_addresses' do
          it 'will filter the cached addresses' do
            get :index,
                params: { country: ip_address[:body][:country].first(2) }

            ip = JSON.parse(response.body).first['ip']
            expect(ip).to eq(ip_address[:body][:ip])
            expect(response).to have_http_status(:ok)
          end
        end

        context "when country doesn't present is cached ip_addresses" do
          it 'will return empty response' do
            get :index, params: { country: 'ABC' }

            expect(JSON.parse(response.body)).to be_empty
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe '#show' do
    context 'when wrong ip address passed' do
      it 'will returns exception' do
        get :show, params: { id: '999.999.999.999' }

        expect(JSON.parse(response.body)['error']).to be_present
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when correct ip address passed' do
      let(:ip_address) do
        { body:
          {
            organization_name: 'GOOGLE',
            accuracy: 1000,
            asn: 15_169,
            organization: 'AS15169 GOOGLE',
            timezone: 'America/Chicago',
            longitude: '-97.822',
            country_code3: 'USA',
            area_code: '0',
            ip: '8.8.8.8',
            country: 'United States',
            continent_code: 'NA',
            country_code: 'US',
            latitude: '37.751'
          },
          status: 200 }
      end

      it 'will returns cached address' do
        allow_any_instance_of(Geo::Location).to(receive(:find_by)
                                            .and_return(ip_address))

        get :show, params: { id: '8.8.8.8' }

        expect(JSON.parse(response.body)['ip']).to eq('8.8.8.8')
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
