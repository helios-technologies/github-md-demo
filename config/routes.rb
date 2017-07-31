Rails.application.routes.draw do
  scope module: 'bootcamp' do
    resources :modules, only: %i[index show new create update destroy], as: 'bootcamp_modules'
  end

  post '/modules/webhook', to: 'bootcamp/modules#webhook'
end
