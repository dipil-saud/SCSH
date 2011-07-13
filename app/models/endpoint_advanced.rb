class Endpoint_advanced
  
  require "rubygems"
  require "sparql_client"
  require'rdf/redland'
  
  attr_accessor :endpoint_string
  attr_accessor :prefix_array  
  attr_accessor :query_predicate
  attr_accessor :result_type
  attr_accessor :result_type_predicate
  attr_accessor :book_title
  attr_accessor :publish_predicate
  attr_accessor :date_predicate
  attr_accessor :chapter_predicate
  attr_accessor :page_predicate
  
  def initialize ( parameter)
    set_attr(parameter )
  end #end initialize
  
  
  
  def set_attr (parameter )#get the endpoint uri from someplace maybe database(yet to be decided)
    self.prefix_array = []
    self.endpoint_string = "http://dblp.l3s.de/d2r/sparql"
    self.prefix_array << "akt: <http://www.aktors.org/ontology/portal#>"
    self.prefix_array << "dc: <http://purl.org/dc/elements/1.1/>"
    self.prefix_array << "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
    self.prefix_array << "swrc: <http://swrc.ontoware.org/ontology#>" 
    self.prefix_array << "dcterms: <http://purl.org/dc/terms/>"
    self.prefix_array << "rdfs: <http://www.w3.org/2000/01/rdf-schema#>"

    self.result_type = "swrc:Book"
    self.result_type_predicate = "rdf:type"
    self.book_title = "dc:title"
    self.publish_predicate = "dc:publisher"
    self.date_predicate = "dcterms:issued"
    self.chapter_predicate = "dcterms:partOf"
    self.page_predicate = "swrc:pages"
    
    
    
  end #end 
  
  
  
  
  def query2 ( title_phrase, publisher_phrase, date_phrase_a, date_phrase_b, chapter_phrase )#, parameter)
    query_string = ""
    ##puts self.prefix_array
    self.prefix_array.each{ |prefix| 
      query_string += "PREFIX " + prefix + ' '
    }
    # #puts publisher_phrase.length
    # #puts date_phrase_a.length
    ##puts date_phrase_b.length
    query_string += "SELECT DISTINCT * WHERE{ "
    query_string += "?result #{self.result_type_predicate} #{self.result_type}. " 
    query_string += "?result " + self.publish_predicate + " ?publisher. " if publisher_phrase.length > 0
    query_string += "?result " + self.date_predicate + " ?date_a. " if date_phrase_a.length > 0
    query_string += "?result " + self.date_predicate + " ?date_b. " if date_phrase_b.length > 0
    query_string += "?result " + self.book_title + " ?object. "
    query_string += "FILTER regex(?object, \"#{title_phrase}\",\"i\")." if title_phrase.length > 0
    if chapter_phrase.length > 0
      query_string += "?chapter " + self.chapter_predicate + " ?result."
      query_string += "?chapter " + self.book_title + " ?ch_title. "
      query_string += "?chapter " + self.page_predicate + " ?pages. "
      query_string += "FILTER regex(?ch_title, \"#{chapter_phrase}\",\"i\")."
    end
    query_string += "FILTER regex(?publisher, \"#{publisher_phrase}\", \"i\"). " if publisher_phrase.length > 0
    
    query_string += "FILTER (?date_a > \"#{date_phrase_a}\") ." if date_phrase_a.length > 0
    query_string += "FILTER (?date_b < \"#{date_phrase_b}\") ." if date_phrase_b.length > 0
    query_string +=  "}"
    query_string += "LIMIT "+6.to_s
    #puts query_string
    
    query = Query_advanced.new
    return query.execute(self.endpoint_string, query_string)
    
  end #end query
  
  def courseQuery(uri)
    
    query_string = ""
    self.prefix_array.each{ |prefix| 
      query_string += "PREFIX " + prefix + ' '
    }
    query_string += "SELECT DISTINCT ?result ?object WHERE{ "
    query_string += "?result #{self.result_type_predicate} #{self.result_type}. " 
    
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    courseModel = Rdfmodel.new($courseFilename)
    uriNode = courseModel.model.get_resource(uri)
    type = uriNode.get_properties(rdf['type'])[0]
    if type == ioe['Course']
      result_title =[]
      result_uri = []
      result_title_temp =[]
      result_uri_temp= []
      courseName = courseModel.model.object(uriNode,ioe['name']).literal.value
      query_string += "?result " + self.book_title + " ?object "
      query_string3 = query_string
      courseName = ".*"+courseName+".*"    
      courseName.gsub!(" ",".*")
      query_string += "FILTER regex(?object, \"#{courseName}\",\"i\")."
      query_string2 = query_string
      #topics
      query_string += "?chapter dcterms:partOf ?result."
      query_string += "?chapter dc:title ?chtitle FILTER( "
      uriNode.get_properties(skos['narrower']).each do |topic|
        topicName = courseModel.model.object(topic,ioe['name']).literal.value
        topicName = ".*"+topicName+".*"    
        topicName.gsub!(" ",".*")
        query_string += "regex( ?chtitle, '#{topicName}','i') ||"
      end      
      query_string.slice!(query_string.length-1)
      query_string.slice!(query_string.length-1)
      query_string += ")."
      query_string +=  "}"
      query_string += "LIMIT "+6.to_s
      ##puts query_string           
      query = Query.new
      result_title_temp, result_uri_temp = query.execute(self.endpoint_string, query_string)
      result_title.concat(result_title_temp)
      result_uri.concat(result_uri_temp)
      
      #references     
      author_array= []
      title_array =[]
      uriNode.get_properties(dcterms['references']).each do |references|
        ref = references.literal.value.partition(',')
        ##puts ref
        author = ref[0]
        title = ref[2]        
        title.gsub!("\"","")
        title.strip!
        title_array << title
        author_array << author        
      end
      query_string = ""
      self.prefix_array.each{ |prefix| 
        query_string += "PREFIX " + prefix + ' '
      }
      query_string += "SELECT DISTINCT ?result ?object WHERE{ "
      query_string += "{ ?result #{self.result_type_predicate} #{self.result_type}. " 
      query_string += "?result " + self.book_title + " ?object "
      query_string += "FILTER ("
      title_array.each do |t|
        t = processed_string(t)
        query_string += " regex(?object, '#{t}', 'i') ||"
      end
      query_string.slice!(query_string.length-1)
      query_string.slice!(query_string.length-1) #remove || at the last
      query_string += "). }"
      query_string += " UNION "
      query_string += "{ ?result #{self.result_type_predicate} #{self.result_type}. " 
      query_string += "?result " + self.book_title + " ?object. "
      query_string += "?result dc:creator ?creator. "
      query_string += "?creator rdfs:label ?name "
      query_string += "FILTER ("
      #query_string +="}"
      ##puts query_string
      author_array.each do |a|
        a = processed_string(a)
        query_string += " regex(?name, '#{a}', 'i') ||"
      end
      query_string.slice!(query_string.length-1)
      query_string.slice!(query_string.length-1) #remove || at the last
      query_string += "). }"
      query_string +=" }"
      ##puts query_string
      result_title_temp, result_uri_temp = query.execute(self.endpoint_string, query_string)
      result_title.concat(result_title_temp)
      result_uri.concat(result_uri_temp)
      
      #final title search
      query_string = query_string2 + "}"
      result_title_temp, result_uri_temp = query.execute(self.endpoint_string, query_string)
      result_title.concat(result_title_temp)
      result_uri.concat(result_uri_temp)
      return result_title, result_uri
      
      
      
      
      
    elsif type == ioe['Topic']
      topicName = courseModel.model.object(uriNode,ioe['name']).literal.value
      query_string += "?result " + self.book_title + " ?object. "
      topicName = ".*"+topicName+".*"    
      topicName.gsub!(" ",".*")
      query_string += "FILTER ( regex(?object, \"#{topicName}\",\"i\")"
      uriNode.get_properties(skos['broader']).each do |course|
        courseName = courseModel.model.object(course,ioe['name']).literal.value
        courseName = ".*"+courseName+".*"    
        courseName.gsub!(" ",".*")
        query_string+= "|| regex(?object, \"#{courseName}\",\"i\")"
      end
      query_string += ")."
      query_string +=  "}"
      query_string += "LIMIT "+6.to_s
      #puts query_string
      query = Query_advanced.new
      return query.execute(self.endpoint_string, query_string)
    end
    
    
  end
  
  def processed_string (string)
    processed = ".*"+string+".*"    
    processed.gsub!(" ",".*")
    return processed
  end
  
end
