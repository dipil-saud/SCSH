class Resource_factory
  
  def create_resource (name, uri)
    Object.const_get("#{name}resource").new(uri)    
  end
  
   def twitter_resource (date, status)
    Object.const_get("Twitterresource").new(date, status)    
  end
end