class User
  
  attr_accessor :username
  attr_accessor :password
  
  def initialize ( usern, pass)
    #puts "user initialize"
    ##puts usern
    ##puts pass
    self.username = usern
    self.password = pass
  end
  
  def authenticate?
    if self.username == "admin" && self.password == "admin"      
      return true
      else return false
    end
  end
  
end