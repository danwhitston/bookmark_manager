require 'bcrypt'

class User

  include DataMapper::Resource



  property :id, Serial
  property :email, String, unique: true, message: 'This email is already taken'

  # stores both password and salt
  property :password_digest, Text
  attr_reader :password
  attr_accessor :password_confirmation


  # this is datamapper's method of validating the model.
  # The model will not be saved unless both password
  # and password_confirmation are the same
  # read more about it in the documentation
  # http://datamapper.org/docs/validations.html
  validates_confirmation_of :password

  # digest implies both hash and salt
  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def self.authenticate(email, password)
    # the user who is trying to sign in
    user = first(email: email)
    # note that == is overridden in the following code
    # by BCrypt::Password.new
    if user && BCrypt::Password.new(user.password_digest) == password
      # return this user
      user
    else
      nil
    end
  end

end
