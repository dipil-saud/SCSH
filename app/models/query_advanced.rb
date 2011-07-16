class Query_advanced
  
  require "rubygems"
  require "sparql_client"
  require 'pp'
  
  def execute (endpoint_string , query_string)
      
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
    
    

  end # end method execute


  def get_result_array (xmldoc) #get result array from result xml data
    result_array = []
    title_array = []
    publisher_array = []
    date_array = []
    chapter_array = []
    ch_uri_array = []
    page_array = []
    xmldoc.each_element('//result') do |result| # check each result element
      
      result.each_element('binding') do |binding|      # values are stored in bindings
        binding_name = binding.attribute('name').to_s.strip     
        result_uri = nil 
        title = nil
        publisher = nil
        date = nil
        chapter = nil
        page = nil
        ch_uri = nil
        binding.each_element('uri') do |uri|       #binding contains uri and literal elements
          result_uri = uri.text if binding_name == 'result'   # get uri value from result  
          ch_uri =  uri.text if binding_name == 'chapter'
        end #end uri do
        binding.each_element('literal') do |literal|       #binding contains uri and literal elements
          title = literal.text if binding_name == 'object'   # get title value from result 
         publisher = literal.text if binding_name == 'publisher'
         chapter = literal.text if binding_name == 'ch_title'
         page = literal.text if binding_name == 'pages'
         date = literal.text if binding_name == 'date_a'
        end #end title do
        result_array << result_uri if result_uri
        title_array << title if title
        publisher_array << publisher if publisher
        date_array << date if date
        chapter_array << chapter if chapter
        page_array << page if page
        ch_uri_array << ch_uri if ch_uri
      end#end binding do
    end#end element do
    return title_array, result_array, publisher_array ,
              date_array ,
            chapter_array, ch_uri_array, page_array 
    
  end #end method get_result_array


end
