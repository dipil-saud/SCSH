module AdminHelper
  
  def logged_in?
    if @user 
      return true
    else
      return false
    end      
  end
   
  
end
