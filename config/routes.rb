Rails.application.routes.draw do
  #resources :messages
  #resources :users
    scope '/:login' do
      get '/' => 'users#anmelden'
      post '/' => 'users#create'
      scope '/message' do
        get '/' => 'messages#getMessage'
        post '/' => 'messages#send'
      end
      scope '/pubkey' do
        get '/' => 'users#pubkey'

      end
    end
end










