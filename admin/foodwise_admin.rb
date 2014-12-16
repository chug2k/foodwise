module Foodwise
  class Admin < Sinatra::Application

    set :sessions,
        :httponly     => true,
        :secure       => production?,
        :expire_after => 31557600, # 1 year
        :secret       => ENV['SESSION_SECRET'] || 'Lumpy Space Princess'

    get '/' do
      slim :login
    end

    # TODO(Charles): If Admin ever feels slow, consider serving assets from Sprockets.
    get '/js/*.js' do
      filename = params[:splat].first
      coffee "../public/js/#{filename}".to_sym
    end
    get '/css/*.css' do
      filename = params[:splat].first
      stylus "../public/css/#{filename}".to_sym
    end


  end
end

