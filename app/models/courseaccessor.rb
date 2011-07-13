class Courseaccessor

  require 'rubygems' 
  require'rdf/redland'
  
  attr_accessor :model
  attr_accessor :uri
  attr_accessor :prefix_string
  attr_accessor :filename
  
  def initialize ( file )
    
    self.model = Redland::Model.new()
    self.filename = file.to_s
    uri_string = "file:"+ self.filename
    uri = Redland::Uri.new(uri_string)
    parser = Redland::Parser.new("rdfxml", "", nil)
    parser.parse_into_model(model, uri)
    
    
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
                          PREFIX ioe: <http://ioe.edu.np/courseOnt#>
                         "
        
  
  end #end initialize
  
  def get_URI
     return self.uri
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
  
  def result_to_array (result)
    
    result_array = []
    while !result.finished?()
      for k in 0..result.bindings_count()-1 #for all values of k from 0 to the last of results
        
        ##puts result.to_string
        ##puts result.binding_value(k)
        s = result.binding_value(k).to_s
        ##puts s
        s = format_result(s)
        
      end         
      result_array << s
      result.next()
      
  end
     return result_array
    
  end
  
  def simple_query (search_string)
    ##puts search_string
    #query_string ="#{self.prefix_string} SELECT ?result WHERE { "
    #?result rdf:type ioe:Topic. "
    #query_string +="FILTER regex(?result, \"course\", \"i\"). "
    #query_string += " ?result rdf:type ioe:Course. "
    #query_string += " ?result rdf:type ioe:Topic. "
    #query_string += " ?result rdf:type ioe:Subtopic. "
    #query_string += " UNION "
    
    query_string ="#{self.prefix_string} SELECT ?result WHERE { "
    query_string += " ?result ioe:name ?object. FILTER regex(?object, '#{search_string}', 'i'). "
    query_string += " } "
    q = Redland::Query.new(query_string,"sparql",nil,nil)
    result = q.execute(self.model)
    result_array = result_to_array(result)
    
    query_string ="#{self.prefix_string} SELECT ?result WHERE { "
    query_string += " ?result ioe:objectives ?object. FILTER regex(?object, '#{search_string}', 'i'). "
    query_string += " } "
    q = Redland::Query.new(query_string,"sparql",nil,nil)
    result = q.execute(self.model)
    result_array.concat( result_to_array(result))
    
    query_string ="#{self.prefix_string} SELECT ?result WHERE { "
    query_string += " ?result ioe:shortDesc ?object. FILTER regex(?object, '#{search_string}', 'i'). "
    query_string += " } "
    q = Redland::Query.new(query_string,"sparql",nil,nil)
    result = q.execute(self.model)
    result_array.concat( result_to_array(result))
    #query_string += " UNION "
    #query_string += "{ ?result ioe:objectives ?object. FILTER regex(?object, '#{search_string}', 'i').}"
    #query_string += "?result ioe:hours ?hours."
    #query_string += "FILTER (?hours > '4'). "
    #query_string +=
    
    ##puts query_string
    
    ##puts result.to_string
    #return result_to_array(result)
    result_array.uniq!
    result_array.sort!
    return result_array
    
  end
  
  def advquery (option, search_string,  objectives, references, 
                hoursLectureOperator, hoursLecture,
                hoursTutorialOperator, hoursTutorial,
                hoursLabOperator, hoursLab,
                hasSchool, publisher,
                hoursOperator, hours,
                shortDesc )
                
                
     query_string ="#{self.prefix_string} SELECT ?result WHERE { "
     #option
     if option != ''
       if option == "Course"
         query_string += " ?result rdf:type ioe:Course. "       
       elsif option == "Topic"
         query_string += " ?result rdf:type ioe:Topic. "
       elsif option == "Subtopic"
         query_string += " ?result rdf:type ioe:Subtopic. "
       else
         
       end
     end
     
     # search_string
     if search_string!= 'nil' && search_string != ''
       
       query_string += " ?result ioe:name ?title. FILTER regex(?title, '#{search_string}', 'i'). "
     end
     
     #objectives
     if objectives !=nil && objectives != ''
       query_string += " ?result ioe:objectives ?objective. FILTER regex(?objective, '#{objectives}', 'i'). "
     end
     
     #references
     if references != nil && references != ''
       query_string += " ?result dcterms:references ?reference. FILTER regex(?reference, '#{references}', 'i'). "
     end
     
     #hoursLecture
     if hoursLecture != nil && hoursLecture != ''
       query_string += "?result ioe:hoursLecture ?hoursLecture."
       #hoursLectureOperator
       if hoursLectureOperator == '>'
          query_string += "FILTER (?hoursLecture > '#{hoursLecture}'). "
       elsif hoursLectureOperator == '<'
         query_string += "FILTER (?hoursLecture < '#{hoursLecture}'). "
       end
     end
     
     #hoursTutorial
     if hoursTutorial != nil && hoursTutorial != ''
       query_string += "?result ioe:hoursTutorial ?hoursTutorial."
       #hoursTutorialOperator
       if hoursTutorialOperator == '>'
          query_string += "FILTER (?hoursTutorial > '#{hoursTutorial}'). "
       elsif hoursTutorialOperator == '<'
         query_string += "FILTER (?hoursTutorial < '#{hoursTutorial}'). "
       end
     end
     
     
     #hoursLab
     if hoursLab != nil && hoursLab != ''
       query_string += "?result ioe:hoursLab ?hoursLab."
       #hoursLabOperator
       if hoursLabOperator == '>'
          query_string += "FILTER (?hoursLab > '#{hoursLab}'). "
       elsif hoursLabOperator == '<'
         query_string += "FILTER (?hoursLab < '#{hoursLab}'). "
       end
     end
     
                    
     #hasSchool
     if hasSchool != nil && hasSchool != ''
       query_string += " ?result ioe:hasSchool ?school. FILTER regex(?school, '#{hasSchool}', 'i'). "
     end
     
     #publisher
     if publisher != nil && publisher != ''
       query_string += " ?result ioe:publisher ?publisher. FILTER regex(?publisher, '#{publisher}', 'i'). "
     end
     
     
     #hours
     if hours != nil  && hours != ''
       query_string += "?result ioe:hours ?hours."
       #hoursOperator
       if hoursOperator == '>'
          query_string += "FILTER (?hours > '#{hours}'). "
       elsif hoursOperator == '<'
         query_string += "FILTER (?hours < '#{hours}'). "
       end
     end
    
     ##puts shortDesc
     if shortDesc != nil && shortDesc != '' 
       query_string += " ?result ioe:shortDesc ?description. FILTER regex(?description, '#{shortDesc}', 'i'). "
     end
     
     
     query_string +="}"
     #puts query_string
     q = Redland::Query.new(query_string,"sparql",nil,nil)
     result = q.execute(self.model)
     result_array = result_to_array(result)
     result_array.uniq!
     result_array.sort!
     return result_array
    
  end
  
end
