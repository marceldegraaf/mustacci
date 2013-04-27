Mustacci::Application.routes.draw do
  resources :pages
  resources :projects

  root to: 'pages#home'
end
