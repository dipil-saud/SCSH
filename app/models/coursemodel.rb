class Coursemodel
  require 'rubygems' 
  require 'rdf/redland'
  include Redland
  
  def initialize ( num )  
     
     
     #initialize fields
     @array = Array.new
     @array << "name"     
     @array << "objectives"
     @array << "hoursLecture"
     @array << "hoursTutorial"
     @array << "hoursLab"
     @array << "publisher"
     @array << "hasSchool"
     @array << "issuedDate"
     1.upto(num) do |n|
       @array << "references#{n}"
    end
    #@nref = num 
    #dynamically create fields and method
    @array.each do |k|
      self.instance_variable_set("@#{k}", "")  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
      #puts self.inspect
      #puts "--------------------------------------------------------"
    end
      #puts self.instance_variables
  end
 
 def array
   @array
 end
 
 def label ( name )
        
   if name == "name"
     return "Title"
   elsif name == "objectives"
     return "Objectives"
   elsif name == "hoursLecture"
     return "Lecture Hours"
   elsif name == "hoursTutorial"
     return "Tutorial Hours"
   elsif name == "hoursLab"
     return "Lab Hours"
   elsif name == "publisher"
     return "Creator of Course"
   elsif name == "hasSchool"
     return "Taught At"
   elsif name == "issuedDate"
     return "Issued On ( YYYY-MM )"
   end
   if name.include? "references"
     return "References"
   end
   
 end
 
 def create (hash)
      hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      
     end
 end
 
 def save
    if self.instance_variable_get("@name") != "" #only save if name given
    #load model
    model=Redland::Model.new()
    raise "Failed to create RDF model" if !model
    filename = $courseFilename.to_s
    uri_string = "file:"+ filename
    uri = Redland::Uri.new(uri_string)
    parser = Redland::Parser.new("rdfxml", "", nil)
    parser.parse_into_model(model, uri)
  
    #create backuppath string
    backuppath = "" + $courseFilename.to_s
    backuppath.insert(-5, "Backup")
    backuppath = backuppath.gsub("db/data/", "db/data/backup/")
    
    model.save(backuppath) 
    
    #load ontology namespaces
    ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    dcterms = Namespace.new("http://purl.org/dc/terms/")
    rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    
    #number of current courses needed to create uri for the new course
    courses = model.subjects(rdf['type'], ioe['Course'])
    coursesIndex =[]
    courses.each do |c|  #get indexes of all the courses 
        coursesIndex << c.uri.to_s.gsub("http://www.ioe.edu.np/scsh/course/course",'').to_i
    end
    
    #puts coursesIndex
    coursesIndex.sort! #sort the indexes
    
    
    
    n = courses.length+1
    temp=1;
    flag= true;
    coursesIndex.each do |i|
                             if temp!=i
                               n = temp if flag == true;
                               flag= false;
                             end
                             temp = temp+1
    end
        
    ##puts n
    #create new course resource
    course = model.create_resource("http://www.ioe.edu.np/scsh/course/course"+n.to_s)
    course.type = ioe['Course']
    
    #create triples in the model
    self.array.each { |name|
                              varname = "@"+name
                              ##puts name
                              value = self.instance_variable_get(varname)
                              if name != "array" && value != ""
                                  ##puts name
                                  if name.include? "references"
                                       if value.include? "http://" #i.e it is a uri
                                        course.add_property( dcterms['references'], Node.new(Uri.new(value)))
                                       else
                                        course.add_property( dcterms['references'], value )
                                       end
                                  else
                                       if value.include? "http://" #i.e it is a uri
                                        course.add_property( ioe[name], Node.new(Uri.new(value)))
                                       else
                                        course.add_property( ioe[name], value )
                                       end
                                  end 
                         end         
                        }
    
    
    
    
    ##puts self.instance_variables
     
     model.save($courseFilename)
     end
    
 end
end
