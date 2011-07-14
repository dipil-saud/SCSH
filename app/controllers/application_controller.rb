# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '22eeb3e01073e0eccd39c6beb9f80c11'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
 
  include ApplicationHelper
  protected

  def login_required
    #puts session[:id]
    if logged_in?
      #puts "user exists"
      return true
    else
      access_denied
      return false  
    end
    
  end
  
  def access_denied
      session[:return_to] = request.request_uri
      #puts session[:return_to]
      #puts "access denied"
      flash[:error] = 'Oops. You need to login before you can view that page.'
      redirect_to :controller => 'admin', :action => 'login'
    end
  
end
