module Foodwise
  class Api < Sinatra::Application
    register Sinatra::ActiveRecordExtension

    DEFAULT_PER_PAGE = 20

    before do
      # Parse any JSON parameters.
      request.body.rewind
      body = request.body.read
      @request_payload = body.empty? ? {} : JSON.parse(body).symbolize_keys

      set_current_user
    end

    helpers do
      def apply_pagination_format_response(relation)
        page = params[:page].to_i || 0
        results = relation.offset(DEFAULT_PER_PAGE * page).limit(DEFAULT_PER_PAGE)
        if results.empty?
          total_count = 0
        else
          total_count = results.first.class.send(:count)
        end
        {
            page: page,
            per_page: DEFAULT_PER_PAGE,
            results: results.to_json,
            total_count: total_count,
            num_pages: total_count / DEFAULT_PER_PAGE
        }.to_json
      end
    end

    get '/' do
      "Hello World! It is currently #{Time.now}"
    end

    get '/users' do
      content_type :json
      halt 401 unless is_admin?

      if params[:query]
        User.where('first_name ILIKE :query OR last_name ILIKE :query OR email ILIKE :query', query: "%#{params[:query]}%").to_json
      else
        User.all.to_json
      end
    end

    post '/product' do
      content_type :json
      halt 401 unless is_admin?

      @product = Product.new(@request_payload)
      if @product.save
        @product.to_json
      else
        halt 500
      end
    end

    get '/product' do
      content_type :json
      Product.find(params[:id]).to_json
    end

    get '/products' do
      content_type :json
      halt 401 unless is_admin?

      relation = Product.all.includes(:category)
      if params[:query]
        relation = relation.where('name ILIKE :query', query: "%#{params[:query]}%")
      end
      if params[:category_id] && params[:category_id].to_i != 0
        relation = relation.where(category_id: params[:category_id])
      end
      apply_pagination_format_response(relation)
    end


    get '/ingredients' do
      content_type :json

      Ingredient.all.to_json
    end

    get '/categories' do
      content_type :json

      Category.all.to_json
    end


    ### Authentication ###

    post '/login' do
      content_type :json
      puts "Logging in user: #{@request_payload[:email]}"
      user = User.find_by_email(@request_payload[:email])
      if user && user.password == @request_payload[:password]  # BCrypt lets us just do a straight compare. Cool!
        t = user.tokens.create(token: SecureRandom.urlsafe_base64(64))
        t.to_json
      else
        halt 401
      end
    end


    private

    def set_current_user
      @current_user = Token.find_by_token(request.env['HTTP_FOODWISE_TOKEN']).try(:user)
    end

    def is_admin?
      @current_user.try(:is_admin)
    end

  end
end

