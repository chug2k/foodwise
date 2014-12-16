class User < ActiveRecord::Base

  def password
    self.password_hash
  end

  def password=(password)
    self.password_hash = BCrypt::Password.create(password)
  end


end

class Token < ActiveRecord::Base
end