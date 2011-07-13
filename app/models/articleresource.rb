class Articleresource < Resource
  
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
                          PREFIX akt: <http://www.aktors.org/ontology/portal#>
                          PREFIX extn: <http://www.aktors.org/ontology/extension#>
                         "
    ##puts uri
  end
  
  def title
    set_uri_article 
    return query "akt:has-title"
  end
  
  def abstract
    return query "extn:has-abstract"
  end
  
  def journal
    journal_uri=[]
    journal_array = []
    journal_uri = query "akt:article-of-journal"
    journal_uri.each{ |journal| 
                                res = Resource.new(journal)
                                journal_a = res.query("akt:has-title")
                                journal_array<<journal_a
                                
                                }
        return journal_array, journal_uri
  end
  
  def uri_see
    uri_array = []
    uri_array = query "akt:has-web-address"
    uri_array += query "akt:has-URL"
    return uri_array
  end
  
  def author
    ##puts self.uri
    authors_uri = []
    author_array=[]
    authors_uri= query "akt:has-author"
   
    authors_uri.each{ |author_uri| 
                                ##puts author_uri
                              res = Resource.new(author_uri)
                              author_a = res.query("akt:full-name")
                              ##puts author_a
                              if author_a.length>0
                                author_array<<author_a[0]
                              else
                                author_array<<" "
                              end
                            }
                      ##puts author_array
    return author_array,authors_uri
  end
  
  def number
    return query "akt:has-number"
  end
  
  def pagenumbers
    return query "akt:has-page-numbers"
  end
    
  def has_volume
    return query "akt:has-volume"
  end
   def date
     date_array=[]
    dates = query "akt:has-date"
    dates.each{ |date| number = date.sub("http://www.aktors.org/ontology/date#"," ")
                        date_array<<number
    }
    return date_array
  end
  
   
  
end