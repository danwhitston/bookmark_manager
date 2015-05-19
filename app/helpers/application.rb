module Application_Helpers # Using fancy style inclusion
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end
