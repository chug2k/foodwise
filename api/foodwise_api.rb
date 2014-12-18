module Foodwise
  class Api < Sinatra::Application
    register Sinatra::ActiveRecordExtension
    use Rack::Deflater

    before do
      # Parse any JSON parameters.
      request.body.rewind
      body = request.body.read
      @request_payload = body.empty? ? {} : JSON.parse(body).symbolize_keys

      set_current_user

    end

    get '/' do
      "Hello World! It is currently #{Time.now}"
    end

    get '/users' do
      content_type :json
      halt 401 unless is_admin?

      puts "Params#: #{params[:query]}"

      if params[:query]
        User.where('first_name ILIKE :query OR last_name ILIKE :query OR email ILIKE :query', query: "%#{params[:query]}%").to_json
      else
        User.all.to_json
      end
    end

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

