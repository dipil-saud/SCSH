class Endpoint_adarticle
  
  require "rubygems"
  require "sparql_client"
  
  attr_accessor :endpoint_string
  attr_accessor :prefix_string  
  attr_accessor :result_type
  attr_accessor :result_type_predicate
  attr_accessor :title_predicate
  attr_accessor :date_predicate
  attr_accessor :author_predicate
  attr_accessor :journal_predicate
  
  def initialize ( parameter)
    set_attr(parameter )
  end #end initialize
  
  def set_attr (parameter )#get the endpoint uri from someplace maybe database(yet to be decided)
    self.prefix_string = ""
    
      self.prefix_string ="PREFIX id:   <http://eprints.rkbexplorer.com/id/>
                            PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                            PREFIX akt:  <http://www.aktors.org/ontology/portal#>
                            PREFIX owl:  <http://www.w3.org/2002/07/owl#>
                            PREFIX akt:  <http://www.aktors.org/ontology/portal#>
                            PREFIX akts: <http://www.aktors.org/ontology/support#>
                            PREFIX dcterms: <http://purl.org/dc/terms/>"
        self.endpoint_string = "http://eprints.rkbexplorer.com/sparql/"
     
        
        self.result_type = "akt:Article-Reference"
        self.result_type_predicate = "rdf:type"
        
        self.title_predicate = "akt:has-title"
      self.date_predicate = "akt:has-date"
      self.journal_predicate = "akt:article-of-journal"
      self.author_predicate = "akt:has-author"

        
     
  end #end 
  
   def query2 (title_phrase, author_phrase, journal_phrase )#, parameter)
    
    query_string = self.prefix_string
   
    query_string += "SELECT DISTINCT ?result ?object WHERE{ "
    query_string += "?result #{self.result_type_predicate} #{self.result_type}. " 
     query_string += "?result " + self.title_predicate + " ?object. "
     
     query_string += "FILTER regex(?object, \"#{title_phrase}\", \"i\"). " if title_phrase.length > 0
     
      if author_phrase.length > 0
      query_string += "?result " + self.author_predicate + " ?author. " 
      query_string += "?author  akt:full-name  ?author_name. "
     query_string += "FILTER regex(?author_name, \"#{author_phrase}\",\"i\")."
    end
    
    if journal_phrase.length > 0
      query_string += "?result " + self.journal_predicate + " ?journal. " 
      query_string += "?journal  akt:has-title  ?journal_name. "
      query_string += "FILTER regex(?journal_name, \"#{journal_phrase}\",\"i\")."
    end
   query_string +=  "}"
    query_string += "LIMIT "+6.to_s
    #puts query_string
    
    query = Query.new
    return query.execute(self.endpoint_string, query_string)
  
  end #end query
 
  end