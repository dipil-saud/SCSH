class Rdfmodel < Resource
  
  require 'rubygems'
  require 'rdf/redland'  
  
  attr_accessor :filename
  
  def initialize (file)
    
    self.model = Redland::Model.new()
    self.filename = file.to_s
    uri_string = "file:"+ self.filename
    uri = Redland::Uri.new(uri_string)
    parser = Redland::Parser.new("rdfxml", "", nil)
    parser.parse_into_model(model, uri)
    
    self.prefix_string = "PREFIX d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#>
                          PREFIX swrc: <http://swrc.ontoware.org/ontology#>
                          PREFIX dcterms: <http://purl.org/dc/terms/>
                          PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                          PREFIX dc: <http://purl.org/dc/elements/1.1/>
                          PREFIX map: <file:///home/diederich/d2r-server-0.3.2/dblp-mapping.n3#>
                          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                          PREFIX foaf: <http://xmlns.com/foaf/0.1/>
                          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                          PREFIX owl: <http://www.w3.org/2002/07/owl#>
                         "
    
    
    
    #savebackup
    #string = ""+self.filename.to_s
    #string.insert(-5, "Backup")
    #string = string.gsub("db/data/", "db/data/backup/")
    
    ##puts string 
    #save(string)
          
  end
  
  def save
    self.model.save(self.filename)
  end
  
  def save_backup
     string = ""+self.filename.to_s
     string.insert(-5, "Backup")
     string = string.gsub("db/data/", "db/data/backup/")
     self.model.save(string)
    
  end
  
  def get_predicates
    ##puts self.uri
    query_string ="SELECT DISTINCT ?result WHERE { <#{self.uri}> ?result ?object }"
    q = Redland::Query.new(query_string)
    result = q.execute(self.model)
    result_array = []
    while !result.finished?()
      for k in 0..result.bindings_count()-1 #for all values of k from 0 to the last of results
        
        s = result.binding_value(k).to_s
        s = format_result(s)
        
      end         
      result_array << s
      result.next()
    end
    ##puts result_array
    return result_array
  end
  
  
   
    
end
