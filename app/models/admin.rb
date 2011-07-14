class Admin
  
  attr_accessor :username
  attr_accessor :password
  
  USERNAME = "scsh"
  PASSWORD = "scsh"
  CRYPT_STRING = "scsh"


  def self.exists?(username, password)
    username == USERNAME && password == PASSWORD
  end
  
  def self.authenticate?(username, password)
    username == USERNAME.crypt(CRYPT_STRING) && password == PASSWORD.crypt(CRYPT_STRING)
  end

  def self.crypted_username
   USERNAME.crypt(CRYPT_STRING)
  end
  
  def self.crypted_password
   PASSWORD.crypt(CRYPT_STRING)
  end
end
