class Twitterresource
    
    attr_accessor :date
    attr_accessor :status
  def initialize (date, status)
    self.date = date
    self.status = status
    
  end
  
  def give_date
    return self.date
  end
  
  def give_status
    return self.status
  end
  
end