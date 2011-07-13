class Facts_endpoint
  
  
  require "rubygems"
  require "sparql_client"
  
  
  attr_accessor :endpoint_string
  attr_accessor :prefix_array  
  attr_accessor :query_predicate
  attr_accessor :result_type
  attr_accessor :result_type_predicate
  attr_accessor :query_label
  
  def initialize (parameter) 
    self.query_predicate = "skos:prefLabel"
    self.query_label = "rdfs:label"
    self.endpoint_string = "http://dbpedia.org/sparql"
    self.prefix_array = "PREFIX owl: <http://www.w3.org/2002/07/owl#>
                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
                            PREFIX dc: <http://purl.org/dc/elements/1.1/>
                            PREFIX : <http://dbpedia.org/resource/>
                            PREFIX dbpedia2: <http://dbpedia.org/property/>
                            PREFIX dbpedia: <http://dbpedia.org/>
                            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>"
    
    
    
  end
  
  
  def query (search_phrase )
    
    query_string = ""
    #search_phrase1=search_phrase.sub(" ",".*")
    search_phrase.capitalize!
    search_phrase1=search_phrase.split
    search_phrase1.each do |x|
      x.capitalize!
    end
    result_title =[]
    result_uri =[]
    result_title2 =[]
    result_uri2 =[]
    ##puts search_phrase1
    #search_phrase[0]=search_phrase[0].capitalize
    ##puts search_phrase
    ##puts self.prefix_array
    query_string += self.prefix_array               
    query_string += "SELECT DISTINCT ?result ?object WHERE{ "
    query_string += "{ ?result " + self.query_label + "\"#{search_phrase}\"@en } UNION "
    query_string += "{ ?result " + self.query_predicate + "\"#{search_phrase}\"@en } "#UNION "#?object "
    query_string += "} LIMIT "+5.to_s
    query = Query.new
    result_title, result_uri = query.execute(self.endpoint_string, query_string)
    
    query_string = ""
    query_string += self.prefix_array  
    query_string += "SELECT DISTINCT ?result ?object WHERE{ "
    k=0;
    search_phrase1.each do |x|
    query_string += " UNION " if k!=0
    query_string += "{ ?result " + self.query_label + "\"#{x}\"@en } UNION "
    query_string += "{ ?result " + self.query_predicate + "\"#{x}\"@en } "
    k=k+1
    end
    #query_string += "{ ?result " + self.query_predicate + "?object "
    #query_string += "FILTER regex(?object, \"#{search_phrase1}\"@en, \"i\"). "+ "}"
    query_string += "} LIMIT "+5.to_s
    
    result_title2, result_uri2 = query.execute(self.endpoint_string, query_string)
    
    result_uri.concat(result_uri2)
    ##puts query_string
    res = Googlesearch.web :q => "site:  site:dbpedia.org dbpedia.org/resource/ #{search_phrase}"
    res ['responseData']['results'].each do |result|
    #print result['title']
    # print "  "
    if result['unescapedUrl'].include?("http://dbpedia.org/resource/")
      #puts result['unescapedUrl']
      result_uri << result['unescapedUrl'] 
    end
    #pp result
    end
    
    res = Googlesearch2.web :q => "site:  site:dbpedia.org dbpedia.org/resource/ #{search_phrase}"
    res ['responseData']['results'].each do |result|
    #print result['title']
    # print "  "
    if result['unescapedUrl'].include?("http://dbpedia.org/resource/")
      #puts result['unescapedUrl']
      result_uri << result['unescapedUrl'] 
    end
    #pp result
  end
    
    result_uri.uniq!
    #query = Query.new
    #return query.execute(self.endpoint_string, query_string)
    ##puts result_title
    ##puts result_uri
    return result_title, result_uri
    
  end #end query
  
  
  
  
  
end