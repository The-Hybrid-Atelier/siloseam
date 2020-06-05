Rails.application.routes.draw do
  get 'tool' =>"silicone#tool", :as => "tool"
  namespace :silicone do 
    get "keys"
  end
  get "motion", action: "motion", controller: "application"
  root 'silicone#tool'
end
