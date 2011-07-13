class Curriculummodel
  
  require 'rubygems'
  require 'rdf/redland'
  include Redland
  
  attr_accessor :model
  attr_accessor :uri
  
  def initialize ()     
    
    @model = load_model()
    @ioe=Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos=Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @rdf=Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @dcterms = Namespace.new("http://purl.org/dc/terms/")
    
  end
  
  def create (name, number, school, courses_uri, semester_no)
    ##puts courses
    ##puts semester_no
    if name != "" && number.to_i < 11
      backuppath = "" + $courseFilename.to_s
      backuppath.insert(-5, "Backup")
      backuppath = backuppath.gsub("db/data/", "db/data/backup/")
      
      @model.save(backuppath) 
      
      courses = @model.subjects(@rdf['type'], @ioe['Curriculum'])
      coursesIndex =[]  
      courses.each do |c|   
        coursesIndex << c.uri.to_s.gsub("http://www.ioe.edu.np/scsh/course/curriculum",'').to_i
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
      ##puts name
      ##puts number.to_i
      @uri = "http://www.ioe.edu.np/scsh/course/curriculum"+n.to_s
      curr = @model.create_resource(@uri)
      curr.type = @ioe['Curriculum']
      curr.add_property( @ioe['name'], name)
      curr.add_property( @ioe['numSem'], number)
      curr.add_property( @ioe['hasSchool'], school)
      num = number.to_i
       (1..num).each { |x|
        sem = @model.create_resource("http://www.ioe.edu.np/scsh/course/curriculum"+n.to_s+"sem"+x.to_s)
        sem.type = @ioe['Semester']
        sem.add_property( @ioe['name'], "Semester "+x.to_s)
        curr.add_property( @ioe['hasSem'], sem )
      }
      
      #add courses
      temp=0;
      courses_uri.each do |course|
        
        sem_no = semester_no[temp].gsub("Semester ",'').to_i
        ##puts course
        object = Node.new(Uri.new(course))
        sem = @model.get_resource(@uri+"sem"+sem_no.to_s)
        ##puts sem
        sem.add_property( @dcterms['hasPart'], object)
        @model.add_statement(Statement.new(object, @dcterms['isPartOf'], sem))    
        temp=  temp+1
      end
      
      
      @model.save($courseFilename)
      
      
      
    end
  end
  
  
  def getCourses
    courseNodes = @model.subjects(@rdf['type'], @ioe['Course'])
    course_names = []
    courses =[]
    courseNodes.each { |course| 
      courses << course.uri.to_s
      course_names << model.object(course, @ioe['name']).literal.value
    }
    
    return courses, course_names
  end  
  
  def get_semester_no
    curriculum = @model.get_resource(@uri)
    return curriculum.get_properties(@ioe['numSem'])[0].literal.value.to_i
  end
  
  def get_semesters
    curriculum = @model.get_resource(@uri)
    semesterNodes = curriculum.get_properties(@ioe['hasSem'])
    semester_names = []
    semesters =[]
    if semesterNodes != nil    
      semesterNodes.each { |semester| 
        semesters << semester.uri.to_s      
      }
      semesters.sort!
      temp = 1;
      semesters.each { |semester|
        semester_names << "Semester"+temp.to_s
        temp=temp+1
      }    
      
    end
    return semesters, semester_names
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
