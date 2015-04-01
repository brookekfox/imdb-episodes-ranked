Rails.application.routes.draw do
  resources :shows
	root 'shows#new'
end
