# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 
  def logged_in?
    session[:scsh_id] && session[:scsh_pass] && Admin.authenticate?(session[:scsh_id], session[:scsh_pass])
  end
   
end
