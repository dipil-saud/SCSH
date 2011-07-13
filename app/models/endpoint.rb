class Endpoint
  
  require "rubygems"
  require "sparql_client"
  
  attr_accessor :endpoint_string
  attr_accessor :prefix_array  
  attr_accessor :query_predicate
  attr_accessor :result_type
  attr_accessor :result_type_predicate
  
  def initialize ( some_parameter)
    
   get_URI
   get_Prefixes
   get_predicate
   get_result_type
   
  end #end initialize
 
  
  def get_URI #get the endpoint uri from someplace maybe database(yet to be decided)
    self.endpoint_string = "http://dblp.l3s.de/d2r/sparql"
    return self.endpoint_string
  end #end get_URI
  
  def get_Prefixes #the prefixes used in the endpoint
    self.prefix_array = []
    self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
    self.prefix_array << "dc: <http://purl.org/dc/elements/1.1/>"
    self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
    self.prefix_array << "swrc: <http://swrc.ontoware.org/ontology#>"  
    return self.prefix_array
  end #end get_Prefixes
  
  def get_predicate #predicate to use in search e.g.dc:title used to search in dblp
    self.query_predicate = "dc:title"
  end #end get_predicate
  
  def get_result_type
    self.result_type = "swrc:Book"
    self.result_type_predicate = "rdf:type"
  end
  
  def query (search_phrase)
    
    query_string = ""
    
    ##puts self.prefix_array
    self.prefix_array.each{ |prefix| 
                       query_string += "PREFIX " + prefix + ' '
                     }
    query_string += "SELECT ?result ?object WHERE{ "
    query_string += "?result #{self.result_type_predicate} #{self.result_type}. " 
    query_string += "?result " + self.query_predicate + " ?object "
    query_string += "FILTER (" 
    query_string += "regex(?object, \"#{search_phrase}\", \"i\")"
    query_string += "|| regex(?object, \"computer\", \"i\")"
    query_string += "|| regex(?object, \"network\", \"i\")"
    query_string += "). }"
    query_string += "ORDER BY (REGEX('#{search_phrase}', ?object))"
    #query_string += "LIMIT "+100.to_s
    ##puts query_string
    query = Query.new
    return query.execute(self.endpoint_string, query_string)
    ##puts result_title
    ##puts result_uri
    #return result_title, result_uri
    
  end #end query
  
end