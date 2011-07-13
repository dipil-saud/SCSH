class Endpointa
  
  require "rubygems"
  require "sparql_client"
  
  attr_accessor :endpoint_string
  attr_accessor :prefix_array  
  attr_accessor :query_predicate
  attr_accessor :result_type
  attr_accessor :result_type_predicate
  
  
  def initialize ( parameter)
    set_attr(parameter )
  end #end initialize
  
  
  
  def set_attr (parameter )#get the endpoint uri from someplace maybe database(yet to be decided)
    self.prefix_array = []
    
    if parameter == "dblp"
      self.endpoint_string = "http://dblp.l3s.de/d2r/sparql"
      self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
        self.prefix_array << "dc: <http://purl.org/dc/elements/1.1/>"
        self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
        self.prefix_array << "swrc: <http://swrc.ontoware.org/ontology#>" 
         self.query_predicate = "dc:title"
         self.result_type = "swrc:Book"
         self.result_type_predicate = "rdf:type"
    
    elsif parameter == "citeseer"
      self.endpoint_string = "http://citeseer.rkbexplorer.com/sparql"
      self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
      self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
        self.query_predicate = "akt:has-title"
        self.result_type = "akt:Article-Reference"
        self.result_type_predicate = "rdf:type"
        
       elsif parameter == "eprint"
      self.endpoint_string = "http://eprints.rkbexplorer.com/sparql/"
      self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
      self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
        self.query_predicate = "akt:has-title"
        self.result_type = "akt:Article-Reference"
        self.result_type_predicate = "rdf:type"
        
    elsif parameter == "dbpedia"
      self.endpoint_string = "http://dbpedia.org/sparql"
      self.prefix_array << "PREFIX owl: <http://www.w3.org/2002/07/owl#>"
      self.prefix_array << "xsd: <http://www.w3.org/2001/XMLSchema#>"
      self.prefix_array << "rdfs: <http://www.w3.org/2000/01/rdf-schema#>"
      self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
      self.prefix_array << "foaf: <http://xmlns.com/foaf/0.1/>"
      self.prefix_array << "dc: <http://purl.org/dc/elements/1.1/>"
      self.prefix_array << ": <http://dbpedia.org/resource/>"
      self.prefix_array << "dbpedia2: <http://dbpedia.org/property/>"
      self.prefix_array << "dbpedia: <http://dbpedia.org/>"
      self.prefix_array << "skos: <http://www.w3.org/2004/02/skos/core#>"
      self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
        self.query_predicate = "akt:has-title"
        self.result_type = "akt:Article-Reference"
        self.result_type_predicate = "rdf:type"
         
   end 
    
    
  end #end 
  
  
  def query (search_phrase )#, parameter)
    
    query_string = ""
    search_phrase = ".*"+search_phrase+".*"
    
    search_phrase.gsub!(" ",".*")
    #puts search_phrase
    ##puts self.prefix_array
    self.prefix_array.each{ |prefix| 
                       query_string += "PREFIX " + prefix + ' '
                     }
    query_string += "SELECT ?result ?object WHERE{ "
    query_string += "?result #{self.result_type_predicate} #{self.result_type}. " 
    query_string += "?result " + self.query_predicate + " ?object "
    query_string += "FILTER regex(?object, \"#{search_phrase}\", \"i\"). "+ "}"
    query_string += "LIMIT "+6.to_s
    ##puts query_string
    
    query = Query.new
    return query.execute(self.endpoint_string, query_string)
    ##puts result_title
    ##puts result_uri
    #return result_title, result_uri
    
  end #end query
  
  
  
  end