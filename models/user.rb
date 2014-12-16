module Foodwise
  class User < ActiveRecord::Base
    has_many :tokens

    def password
      @password ||= BCrypt::Password.new(password_hash)
    end

    def password=(password)
      self.password_hash = BCrypt::Password.create(password)
    end


  end

  class Token < ActiveRecord::Base
    belongs_to :user
  end

end
