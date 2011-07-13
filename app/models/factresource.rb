class Factresource < Resource
  
  
  def initialize uri
    super uri
    self.prefix_string = "PREFIX owl: <http://www.w3.org/2002/07/owl#>
                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
                            PREFIX dc: <http://purl.org/dc/elements/1.1/>
                            PREFIX : <http://dbpedia.org/resource/>
                            PREFIX dbpedia2: <http://dbpedia.org/property/>
                            PREFIX dbpedia: <http://dbpedia.org/>
                            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>"
      #puts uri
  end
  
  
     def title
    set_uri_fact
    return query "skos:prefLabel"
    ##puts ret
  end
  
  def part_of
    return query "skos:broader"
  end
  
  def contains_topics
    return query_as_object "skos:broader"
  end
  
  def contains_subjects
    return query_as_object "skos:subject"
  end
 
  def label
    set_uri_fact
    return query "rdfs:label"
  end
  
  def abstract
    return query "<http://dbpedia.org/ontology/abstract>"
  end
  
  def wikipage
    return query "foaf:page"
  end
  
  def people_associated
    return query_as_object "<http://dbpedia.org/ontology/knownFor>"
  end
  def subject_category
    return query "skos:subject"
  end
  def same_as
    return query "owl:sameAs"
    
  end
  def photo
    return query "dbpedia2:hasPhotoCollection"
  end
 def references
   return query "dbpedia2:reference"
 end
 
 def comment
   return query "rdfs:comment"
 end
 
 def thumbnail
  
   imageLink = query "<http://dbpedia.org/ontology/thumbnail>"
   return imageLink
 end
 def depiction
   
   imageLink = query "foaf:depiction"
   return imageLink
 end
end