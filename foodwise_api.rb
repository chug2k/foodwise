class FoodwiseAPI < Sinatra::Application
  register Sinatra::ActiveRecordExtension
  require_relative 'models/user'

  before do
    # Parse any JSON parameters.
    request.body.rewind
    body = request.body.read
    @request_payload = body.empty? ? {} : JSON.parse(body).symbolize_keys

    #TODO(Charles): Parse any header login information.


  end


  get '/' do
    "Hello World! It is currently #{Time.now}"
  end

  post '/login' do
    puts "Logging in user: #{@request_payload[:email]}"
    user = User.find_by_email(@request_payload[:email])
    if user && user.password == @request_payload[:password]  # BCrypt lets us just do a straight compare. Cool!
      Token.create(
          user_id: user.id,
          token: SecureRandom.urlsafe_base64(64)
      )
    else
      halt 401
    end
  end

end
