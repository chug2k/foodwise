module Foodwise
  require 'ostruct'
  class Admin < Sinatra::Application
    configure :development do
      register Sinatra::Reloader
    end
    use Rack::Deflater

    class ApiClient
      include HTTParty
      headers 'Content-Type' => 'application/json'
      base_uri ENV['FOODWISE_API_URL'] || 'http://localhost:9393/api'

      def users(token, query)
        self.class.get('/users', query: {query: query}, headers: {'Foodwise-Token' => token})
      end

      def products(token, category_id, query, page)
        self.class.get('/products',
                       query:
                           {category_id: category_id, query: query, page: page},
                       headers: {'Foodwise-Token' => token})
      end

      def product(token, id)
        self.class.get("/product/#{id}", headers: {'Foodwise-Token' => token})
      end

      def create_product(token, product_params)
        self.class.post('/product', body: product_params.to_json, headers: {'Foodwise-Token' => token})
      end

      def delete_product(token, product_id)
        self.class.delete("/product/#{product_id}", headers: {'Content-Type' => 'application/json'})
      end

      def login(credentials)
        self.class.post('/login', body: credentials.to_json, headers: {'Content-Type' => 'application/json'})
      end

      def categories
        self.class.get('/categories', headers: {'Content-Type' => 'application/json'})
      end

    end

    @@api = ApiClient.new
    enable :sessions
    set :session_secret, ENV['SESSION_KEY'] || 'Can of Beans'

    register Sinatra::Flash

    helpers do
      def logged_in?
        session[:user_token] != nil
      end
    end

    def current_user_token
      session[:user_token]
    end


    @@categories = []
    before do
      if @@categories.empty?
        @@categories = @@api.categories.parsed_response.collect{ |x| OpenStruct.new(x)}
      end

      @categories = @@categories
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
        puts "my token is #{res['token']}"
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
      res = @@api.products(session[:user_token],
                           params[:category_id],
                           params[:query],
                           params[:page]).parsed_response
      @products = JSON.parse(res['results']).collect {|x| OpenStruct.new(x)}
      @page = res['page'].to_i
      @num_pages = res['num_pages']
      @total_count = res['total_count']
      slim :products
    end

    get '/product/new' do
      halt 401 unless logged_in?
      @product = OpenStruct.new
      slim :product
    end

    get '/product/:id/alternatives' do
      res = @@api.product session[:user_token], params[:id]
      @product = OpenStruct.new(res.parsed_response)

      @product1 = Product.where('id NOT IN (?)', @product.id).first
      @product2 = Product.where('id NOT IN (?)', @product.id).last

      slim :product_alternatives
    end

    get '/product/:id/delete' do
      res = @@api.delete_product session[:user_token], params[:id]
      p res
      @product = OpenStruct.new(res.parsed_response)

      flash[:info] = "#{@product.brand}: #{@product.name} successfully deleted."
      redirect back
    end

    get '/product/:id' do |n|
      halt 401 unless logged_in?
      res = @@api.product session[:user_token], params[:id]
      @product = OpenStruct.new(res.parsed_response)
      slim :product
    end

    post '/product' do
      halt 401 unless logged_in?
      res = @@api.create_product session[:user_token], params
      halt 500 unless res.code == 200
      flash[:info] = "#{params[:name]} successfully created/updated!"
      redirect url '/product/new', 301
    end

    get '/users' do
      puts "Am I logged in? #{logged_in?}"
      puts "I think I am: #{session[:user_token]}"
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

