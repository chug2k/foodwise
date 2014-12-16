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

    post '/login' do
      puts "Logging in user: #{@request_payload[:email]}"
      user = User.find_by_email(@request_payload[:email])
      if user && user.password == @request_payload[:password]  # BCrypt lets us just do a straight compare. Cool!
        user.tokens.create(token: SecureRandom.urlsafe_base64(64))
      else
        halt 401
      end
    end


    private

    def set_current_user
      @current_user = Token.find_by_token(headers['FWTOKEN']).try(:user)
    end

  end
end

