class AdminController < ApplicationController
  
 
  before_filter :login_required, :only => [:admin_page, :logout]
  
  
  def initialize
    
  end
  
  def login
    
  end
  
  def process_login
    #puts params[:user]
    #puts params[:pass]
    #authenticate
    @user = User.new(params[:user], params[:pass])
    if @user.authenticate?
      id = params[:user] + "1"  # get the id of the user
      session[:id] = id
      #puts params[:return_to]
      if params[:return_to]        
        redirect_to params[:return_to]
      else 
        #puts "redirect"
        redirect_to :action => "admin_page"
      end
    else
        flash[:error] = 'Invalid login.'
        redirect_to :action => 'login'
    end 
  end
  
  
  def logout
      reset_session
      flash[:message] = 'Logged out.'
      redirect_to :action => 'login'
  end
  
  def admin_page
    #reset_session
    #puts logged_in?
  end
  
  def logged_in?
    if @user 
      return true
    else
      return false
    end      
  end
  
  
  def admin_view
    render :action => nil
  end
  
  def admin_add
    render :action => nil
  end
  
  def admin_update
    render :action => nil
  end
  
  def add
    #puts params[:title]
    #puts params[:school]
    #puts params[:abstract]
    #puts params[:publisher]
    #puts params[:uploader]
    #puts params[:issued]
    #puts params[:modified]
    #puts params[:references]
    
    
  end

end  
  

