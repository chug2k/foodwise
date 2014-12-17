module Foodwise
  class Admin < Sinatra::Application

    set :sessions,
        :httponly     => true,
        :secure       => production?,
        :expire_after => 31557600, # 1 year
        :secret       => ENV['SESSION_SECRET'] || 'Lumpy Space Princess'


    helpers do
      def login?
        if session[:user_id].nil?
          return false
        else
          return true
        end
      end


      def current_user
        return session[:user_id]
      end

    end


    get '/' do
      slim :login
    end

    post '/login' do
      puts "Params are: #{params}"

      # session[:username] = params[:username]
    end


    # TODO(Charles): If Admin ever feels slow, consider serving assets from Sprockets.
    get '/js/*.js' do
      filename = params[:splat].first
      if File.exist?("../public/js//#{viewname}.coffee")
        coffee "../public/js/#{filename}".to_sym
      end
    end

    get '/css/*.css' do
      filename = params[:splat].first
      if File.exist?("../public/css/#{filename}.styl")
        stylus "../public/css/#{filename}".to_sym
      end
    end

  end
end

