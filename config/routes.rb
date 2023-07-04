# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get :status, action: :show, controller: :statuses

      resources :locations, only: %i[index show],
                            id: /([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/
    end
  end
end
