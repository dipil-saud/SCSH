class Subtopicmodel
  
  require 'rubygems'
  require 'rdf/redland'
  include Redland
  
  def initialize ( num )
    @array = Array.new
    @array << "name"
    @array << "shortDesc"
    1.upto(num) do |n|
      @array << "isPartOf#{n}"
    end
    
    @model = load_model()
    
    @array.each do |k|
      self.instance_variable_set("@#{k}", nil)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
    
  end

  def create (hash)
      hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      end
      
  end

  def save
    if self.instance_variable_get("@name") != "Sub-Topic Name"
    #model = load_model()
    backuppath = "" + $courseFilename.to_s
    backuppath.insert(-5, "Backup")
    backuppath = backuppath.gsub("db/data/", "db/data/backup/")
    
    @model.save(backuppath) 
    
    #load ontology namespaces
    ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    dcterms = Namespace.new("http://purl.org/dc/terms/")
    rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    
    #number of current topics needed to create uri for the new topic , courses means subtopics here
    courses = @model.subjects(rdf['type'], ioe['Subtopic'])
    coursesIndex =[]
    courses.each do |c|  #get indexes of all the courses 
        coursesIndex << c.uri.to_s.gsub("http://www.ioe.edu.np/scsh/course/subtopic",'').to_i
    end
    coursesIndex.sort! #sort the indexes        
    n = courses.length+1
    temp=1;
    flag = true;
    coursesIndex.each do |i|
                             if temp!=i
                               n = temp if flag == true;
                               flag= false;
                             end
                             temp = temp+1
    end
    
    
    #create new course resource
    topic = @model.create_resource("http://www.ioe.edu.np/scsh/course/subtopic"+n.to_s)
    topic.type = ioe['Subtopic']
    
    @array.each { |name|
                            varname = "@"+name
                            ##puts name
                            value = self.instance_variable_get(varname)
                            if name != "array" && value != "" && value != "Short Description"
                              if name.include? "isPartOf"
                              object = Node.new(Uri.new(self.instance_variable_get(varname)))
                              topic.add_property( dcterms['isPartOf'], object )
                              @model.add_statement( Statement.new(object, dcterms['hasPart'], topic) )
                              
                              else
                                       if value.include? "http://" #i.e it is a uri
                                        topic.add_property( ioe[name], Node.new(Uri.new(value)))
                                       else
                                        topic.add_property( ioe[name], value )
                                       end                       
                              end
                            end
                         }
    
    
    
    
    ##puts self.instance_variables
     
     @model.save($courseFilename)
    end
 end
 
  def getCourses
    
    rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    #@model = load_model()
    courseNodes = @model.subjects(rdf['type'],ioe['Course'])
    course_names = []
    courses =[]
    courseNodes.each { |course| 
                   courses << course.uri.to_s
                   course_names << @model.object(course, ioe['name']).literal.value
                 }
    
    return courses, course_names
    
  end
  
  def getCourseTopics ( courseUri )
    rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    skos=Namespace.new("http://www.w3.org/2004/02/skos/core#")
    topics =[]
    topic_names =[]
    courseNode = @model.create_resource(courseUri)
    courseNode.get_properties(skos['narrower']).each do |topic|
      topics << topic.uri.to_s
      topic_names << @model.object(topic, ioe['name']).literal.value
    end
    return topics, topic_names
  end
  
  def getTopics
    rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    #@model = load_model()
    topicNodes = @model.subjects(rdf['type'],ioe['Topic'])
    topic_names = []
    topics =[]
    topicNodes.each { |topic| 
                   topics << topic.uri.to_s
                   topic_names << @model.object(topic, ioe['name']).literal.value
                 }
    
    return topics, topic_names
  end
  
  def load_model
    model=Redland::Model.new()
    raise "Failed to create RDF model" if !model
    filename = $courseFilename.to_s
    uri_string = "file:"+ filename
    uri = Redland::Uri.new(uri_string)
    parser = Redland::Parser.new("rdfxml", "", nil)
    parser.parse_into_model(model, uri)
    return model
  end

end
