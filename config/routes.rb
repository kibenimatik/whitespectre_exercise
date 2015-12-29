Rails.application.routes.draw do
  resources :group_events do
    patch :publish, on: :member
    patch :unpublish, on: :member
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
