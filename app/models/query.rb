class Query
  
  require "rubygems"
  require "sparql_client"
  require 'pp'
  
  def execute (endpoint_string , query_string)
      
      search_phrase = "java"
      endpoint="http://dblp.l3s.de/d2r/sparql"
       qs="
     PREFIX akt:  <http://www.aktors.org/ontology/portal#>
     PREFIX dc: <http://purl.org/dc/elements/1.1/>
     SELECT ?result WHERE {
     ?result  dc:title ?title FILTER regex(?title, \"#{search_phrase}\", \"i\") .
     
    }
    LIMIT 2"
    # endpoint_string
    # query_string
    sparql = SPARQL::SPARQLWrapper.new(endpoint_string)
    sparql.query_string = query_string
    ret = sparql.query
    if ret != nil
      xmldoc = ret.convertXML
      return get_result_array(xmldoc)
    else
      array1 = []
      array2 = []
      return array1, array2
    end
    #return result_array

  end # end method execute


  def get_result_array (xmldoc) #get result array from result xml data
    result_array = []
    title_array = []
    xmldoc.each_element('//result') do |result| # check each result element
      
      result.each_element('binding') do |binding|      # values are stored in bindings
        binding_name = binding.attribute('name').to_s.strip     
        result_uri = nil 
        title = nil
        binding.each_element('uri') do |uri|       #binding contains uri and literal elements
          result_uri = uri.text if binding_name == 'result'   # get uri value from result  
        end #end uri do
        binding.each_element('literal') do |literal|       #binding contains uri and literal elements
          title = literal.text if binding_name == 'object'   # get title value from result  
        end #end title do
        result_array << result_uri if result_uri
        title_array << title if title
      end#end binding do
    end#end element do
    return title_array, result_array  
  end #end method get_result_array


end
