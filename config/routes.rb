SmartAnswers::Application.routes.draw do
  get '/:slug', :to => 'smart_answer#landing'
  get '/:slug/y(/*responses)', :to => 'smartanswer#in_flow'

  match '/:id(/:started(/*responses)).:format',
    :to => 'smart_answers#show',
    :as => :formatted_smart_answer,
    :constraints => { :format => /[a-zA-Z]+/ }

  match '/:id(/:started(/*responses))', :to => 'smart_answers#show', :as => :smart_answer
end
