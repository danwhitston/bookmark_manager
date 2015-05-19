require 'data_mapper'
require 'sinatra/base'
require 'rack-flash'

require_relative 'data_mapper_setup'
require_relative 'helpers/application'

require './lib/link' # this needs to be done after datamapper is initialised
require './lib/tag'
require './lib/user'

class BookmarkManager < Sinatra::Base

  helpers Application_Helpers #Calling helpers on a module!
  # require_relative 'helpers/application'

  enable :sessions
  set :session_secret, 'super secret'

  set :views, Proc.new { File.join(root, "views") }
  set :public_folder, Proc.new { File.join(root, "..", "public") }

  use Rack::Flash

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params['url']
    title = params['title']
    tags = params['tags'].split(' ').map do |tag|
      Tag.first_or_create(text: tag)
    end
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    # Create a user as the view references it
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    # Initialize the object in memory so we can check validity without losing
    @user = User.new(email: params[:email],
                       password: params[:password],
                       password_confirmation: params[:password_confirmation])
    # Try to save the form submission
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
      # If that doesn't work, show the prepopulated form
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

end
