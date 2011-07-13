RPH::Navigation::Builder.config do |navigate|
  navigate.define :primary do |menu|
    menu.item :index, :text => 'Home'
    menu.item :search, :text => 'Search' do |sub_menu|
      sub_menu.item :advBook, :text => 'Advanced Book Search', :path => 'advBook_search_path'
      sub_menu.item :advArticle, :text => 'Advanced Article Search', :path => 'advArticle_search_path'
    end
    menu.item :course, :text => 'Course' do |sub_menu|      
      sub_menu.item :search, :text => 'Search Course', :path => 'course_search_path'
      sub_menu.item :fullview, :text => 'Full View', :path => 'fullview_path'
      sub_menu.item :view, :text => 'View Details', :path => 'course_view_path'
    end
    menu.item AdminController, :text => 'Admin',:if => Proc.new { |view| view.logged_in? } do |sub_menu|      
      sub_menu.item :addnew, :text => 'Add', :path => 'addnew_path', :if => Proc.new { |view| view.logged_in? }
      sub_menu.item :view, :text => 'View', :path => 'adminview_path', :if => Proc.new { |view| view.logged_in? }
      sub_menu.item :update, :text => 'Update', :path => 'update_path', :if => Proc.new { |view| view.logged_in? }      
      sub_menu.item :logout, :text => 'Logout', :path => 'logout_path', :if => Proc.new { |view| view.logged_in? }
      sub_menu.item :login, :text => 'Login', :path => 'login_path', :if => Proc.new { |view| !view.logged_in? }
    end      
   
    
  end
end
