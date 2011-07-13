class Bookresource < Resource
  
  
  attr_accessor :predicates
  
  def initialize uri
    super uri
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
   end
   
     def setPrefix pstring
       self.prefix_string = pstring
     end
     
     def addPrefix pstring
       self.prefix_string += pstring
     end
 
     def title
         return query "dc:title"
     end
     
     def authors
         return query "dc:creator"
     end
     def publisher
       return query "dc:publisher"
     end
     def isbn
         return query "swrc:isbn"
     end
     
     def issued
         return query "dcterms:issued"
     end
     
     def actual_link
         return query "rdfs:seeAlso"
     end
     
     def cover_image
       imageLink = "/images/noimage.jpeg"
       isbn = self.isbn
       if isbn[0]
              isbnTemp = isbn[0]
              isbnTemp = isbnTemp.gsub("ISBN",'')
              isbnTemp = isbnTemp.gsub(' ','')
              isbnTemp = isbnTemp.gsub('-','')
              ##puts isbnTemp
              imageLink = "http://images.amazon.com/images/P/#{isbnTemp}.01.ZTZZZZZZ.jpg"
       end
       return imageLink
     end
     
     def chapters
          chapters = []
          pages = []
          chapters_uri = []
          chapters_uri = query_as_object("dcterms:partOf")
          chapters_uri.each{ |chapter| 
                                       rs = Resource.new(chapter)
                                       title_a = rs.query("dc:title")
                                       pages_a = rs.query("swrc:pages")
                                       if title_a.length > 0
                                         chapters << title_a[0] 
                                       else
                                         chapters << " "                                       
                                       end                                       
                                       if pages_a.length > 0
                                         pages << pages_a[0] 
                                       else
                                         pages << " "                                       
                                       end                                       
                            }
           return chapters, pages
            
     end
     
 
 
 
 
    
 
 
  
  
end