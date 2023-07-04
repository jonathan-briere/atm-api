# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get :status, action: :show, controller: :statuses
    end
  end
end
