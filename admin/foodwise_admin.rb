module Foodwise
  class Admin < Sinatra::Application
    class ApiClient
      include HTTParty
      base_uri 'http://localhost:9393/api' # TODO(Charles): Fix when uploading. =)

      def users
        self.class.get('/users')
      end

    end

    @@api = ApiClient.new

    set :sessions,
        :httponly     => true,
        :secure       => production?,
        :expire_after => 31557600, # 1 year
        :secret       => ENV['SESSION_SECRET'] || 'Lumpy Space Princess'

    register Sinatra::Flash

    helpers do
      def logged_in?
        session[:user_id].present?
      end


      def current_user
        return session[:user_id]
      end

    end


    get '/' do
      slim :login
    end

    post '/login' do
      u = User.find_by_email(params[:email])
      if u && u.password == params[:password]
        session[:user_id] = u.id
        redirect url :products
      else
        flash[:error] = 'Your login details were incorrect.'
        redirect url :/, 301
      end
    end

    post '/logout' do
      session[:user_id] = nil
      flash[:error] = 'You have been logged out.'
      redirect url :/, 301
    end

    get '/products' do
      halt 401 unless logged_in?
      slim :products
    end

    get '/users' do
      halt 401 unless logged_in?

      puts @@api.users

      slim :users
    end



    # TODO(Charles): If Admin ever feels slow, consider serving assets from Sprockets.
    get '/js/*.js' do
      filename = params[:splat].first
      if File.exist?("../public/js//#{viewname}.coffee")
        coffee "../public/js/#{filename}".to_sym
      end
    end

    get '/css/*.css' do
      content_type 'text/css'
      filename = params[:splat].first
      stylus "../public/css/#{filename}".to_sym
    end

  end
end

