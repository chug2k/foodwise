module Foodwise
  require 'ostruct'
  class Admin < Sinatra::Application
    class ApiClient
      include HTTParty
      headers 'Content-Type' => 'application/json'
      base_uri 'http://localhost:9393/api' # TODO(Charles): Fix when uploading. =)

      def users(token, query)
        self.class.get('/users', query: {query: query}, headers: {'Foodwise-Token' => token})
      end

      def login(credentials)
        self.class.post('/login', body: credentials.to_json, headers: {'Content-Type' => 'application/json'})
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
        session[:user_token] != nil
      end
    end

    def current_user_token
      session[:user_token]
    end

    get '/' do
      slim :login
    end

    post '/login' do
      res = @@api.login(params)
      if res.code == 401
        flash[:error] = 'Your login details were incorrect.'
        redirect url :/, 301
      else
        res = res.parsed_response
        halt 500 unless res.has_key? 'token'
        session[:user_token] = res['token']
        redirect url :users
      end
    end

    post '/logout' do
      session[:user_token] = nil
      flash[:error] = 'You have been logged out.'
      redirect url :/, 301
    end

    get '/products' do
      halt 401 unless logged_in?
      slim :products
    end

    get '/product/new' do
      halt 401 unless logged_in?
      @product = OpenStruct.new
      slim :product
    end

    get '/users' do
      halt 401 unless logged_in?
      res = @@api.users session[:user_token], params[:query]
      @users = res.parsed_response.each {|x| x.symbolize_keys!}
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

