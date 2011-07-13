class Resource

  require 'rubygems'
  require'rdf/redland'
  
  attr_accessor :model
  attr_accessor :uri
  attr_accessor :prefix_string
  
  
  def initialize ( uri_string )
    
    self.uri = uri_string
    self.model = Redland::Model.new
    #default namespaces
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
                          PREFIX akt: <http://www.aktors.org/ontology/portal#>
                         "
        
    uri_object_redland = Redland::Uri.new(uri_string)    
    parser = Redland::Parser.new
    parser.parse_into_model(self.model, uri_object_redland)
  
  end #end initialize
  
  def get_URI
     return self.uri
 end
 
 def set_uri_article 
    self.uri=self.uri.sub("data","id")
    #puts self.uri
  end
  
  def set_uri_fact
    self.uri = self.uri.sub("data","resource")
    self.uri = self.uri.sub(".rdf","")
    ##puts self.uri
  end
  
  def format_result ( result_string)
  
      s=result_string.gsub('[','').gsub(']','') #converts the result uri which is in [ ] to actual uri       
      s=s.gsub('"','').gsub('"','').gsub('<','').gsub('>','')
      i = s.index('^^')
      
      if i
      s.slice!(i..s.length)  
      end      
      return s
  
  end # end format_result
  
  def query ( predicate_string )
    ##puts self.uri
    query_string ="#{self.prefix_string} SELECT ?result WHERE { <#{self.uri}> #{predicate_string} ?result.  "
    query_string += "FILTER langMatches(lang(?result),\"en\")" if predicate_string == "rdfs:label"|| predicate_string == "<http://dbpedia.org/ontology/abstract>"||predicate_string == "rdfs:comment"
    query_string += " }"
    #puts query_string
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
  end #end query
  
    
  def query_as_object ( predicate_string )
    
    query_string ="#{self.prefix_string} SELECT ?result WHERE {  ?result #{predicate_string} <#{self.uri}>. } "
    
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
  end #end query
  
  
end
