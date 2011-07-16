class CourseController < ApplicationController
  require 'rubygems'
  
  require'rdf/redland'
  require 'pp'

  def new_select
    @select_array = ["Course", "Topic", "Subtopic", "Curriculum"]
    render :layout => false if params[:navigation]
  end
  
  def process_select
    if params[:id] == "Course"
      redirect_to :action => "new"
    elsif params[:id] == "Topic"
      redirect_to :action => "new_topic"
    elsif params[:id] == 'Subtopic'
      redirect_to :action => "new_subtopic"
    elsif params[:id] == "Curriculum"
      redirect_to :action => "new_curriculum"
    else
      redirect_to :action => 'new_select'
    end
  end
  
  def new    
    
    if params[:no]== nil #params[:no] is the number of references
      @no = 5
    else
      
      #puts params[:no]
      @no = params[:no].to_i
    end    
    
    @course = Coursemodel.new(@no)
  end
  
  def new_topic
    
    if params[:no]== nil #params[:no] is the number of references
      @no = 1
    else
      
      #puts params[:no]
      @no = params[:no].to_i
    end    
    
    @topic = Topicmodel.new(@no)
    @courses = []
    @coursenames = []
    @courses, @coursenames = @topic.getCourses
    #puts @courses
    #puts @coursenames
  end
  
  def new_subtopic
    if params[:no]== nil 
      @no = 1
    else
      
      #puts params[:no]
      @no = params[:no].to_i
    end    
    
    @subtopic = Subtopicmodel.new(@no)
    @topics = []
    @topicnames = []
    #@topics, @topicnames = @subtopic.getTopics
    @courses, @coursenames = @subtopic.getCourses
    @topics, @topicnames = @subtopic.getCourseTopics(@courses[0])
    #puts @courses
    #puts @coursenames
  end
  
  def course_topic_list
    #puts params[:courseUri]
    @num = params[:num]
    @subtopic = Subtopicmodel.new(1)
    @topics, @topicnames = @subtopic.getCourseTopics(params[:courseUri])
    
    render :layout => false  
    
  end
  
  def create
    #puts "create invoked"
    #puts params[:course]
    
    if params[:no]== nil
      @no = 5
    else
      
      #puts params[:no]
      @no = params[:no].to_i
    end
    #puts params[:coursemodel]
    @course = Coursemodel.new(@no)
    @course.create(params[:coursemodel])
    @course.save
    #puts @course.instance_variable_names
    redirect_to :controller => "admin", :action => "admin_page"
    
  end
  
  def create_topic
    #puts "topic create invoked"
    
    
    if params[:no]== nil
      @no = 1
    else
      
      #puts params[:no]
      @no = params[:no].to_i
    end
    #puts params[:topicmodel]
    @topic = Topicmodel.new(@no)
    @topic.create(params[:topicmodel])
    @topic.save
    
    redirect_to :controller => "admin", :action => "admin_page"
    
  end
  
  def create_subtopic
    #puts "subtopic create invoked"
     
    subtopic = Hash.new
    subtopic['name'] = params[:name][0]
    subtopic['shortDesc'] = params[:shortDesc][0]
    
    
    if params[:no]== nil
      @no = 1
      subtopic['isPartOf1'] = params['isPartOf1']
    else
      
      #puts params[:no]
      @no = params[:no].to_i
      (1..@no).each do |n|
        subtopic['isPartOf'+n.to_s] = params['isPartOf'+n.to_s]
      end
    end
    pp subtopic
    @subtopic = Subtopicmodel.new(@no)
    @subtopic.create(subtopic)
    @subtopic.save
   
    redirect_to :controller => "admin", :action => "admin_page"
    
  end
  
  def create_curriculum   
    
    curriculum = Curriculummodel.new();   
    curriculum.create(params[:name], params[:number], params[:hasSchool], params[:course_uri], params[:semester_no]) 
    ##puts params[:semester_no]   
    
    redirect_to :controller => "admin", :action => "admin_page"
    
  end
  
  def add_courses
    if params[:number]!=''
      curriculum = Curriculummodel.new();
      @courses, @coursenames = curriculum.getCourses
      @semesters =[]
       (1..params[:number].to_i).each { |num|
        @semesters << "Semester " + num.to_s
      }
    
    end
    render :layout => false
  end
  
  def update_courses_curriculum
    dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    courses = params[:course_uri]
    semesters = params[:semester_no]
    courseModel = Rdfmodel.new($courseFilename)
    temp = 0;
    courses.each do |course|
      courseNode = Redland::Node.new(Redland::Uri.new(course))
      semesterNode = Redland::Node.new(Redland::Uri.new(semesters[temp]))
      courseModel.model.add_statement(Redland::Statement.new(courseNode, dcterms['isPartOf'], semesterNode)) 
      courseModel.model.add_statement(Redland::Statement.new(semesterNode, dcterms['hasPart'], courseNode))
      ##puts courseNode
      ##puts semesterNode
      temp= temp+1
    end
    courseModel.save 
    redirect_to :action => 'edit', :uri => params[:uri]
  end
  
  def view
    
    @select_array = ["Course", "Topic", "Subtopic", "Curriculum"]
    
  end
  
  def view_select
    ioe=Redland::Namespace.new("http://ioe.edu.np/courseOnt#")    
    rdf=Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @names = []
    @uris = []
    if logged_in?
      @redirect = "edit"
    else
      @redirect = "view_details"
    end
    
    @select = params[:id]
    @courseModel = Rdfmodel.new($courseFilename)
    if params[:id] == "Course"
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Course'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }
    elsif params[:id] == "Topic"
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Topic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
    elsif params[:id] == "Subtopic"
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Subtopic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
    elsif params[:id] == "Curriculum"
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Curriculum'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
      
    end
    render :layout => false
  end
  
  def view_details
    ##puts params[:uri]
    if params[:uri] != "Select  Topic" &&  params[:uri] != "Select  Subtopic" && params[:uri] != "Select  Course" && params[:uri] != "Select  Curriculum"
      ##puts params[:uri]
      @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
      @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
      @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
      @courseModel = Rdfmodel.new($courseFilename)
      @courseModel.uri = params[:uri]
      @nameModel = Rdfmodel.new($ontNames)
      ##puts params[:uri]
      
      @predicates = @courseModel.get_predicates
      @subject = @courseModel.model.get_resource(params[:uri])
      @subject_type = @subject.get_properties(@rdf['type'])[0]
      ##puts @subject
      ##puts @predicates

      ##puts @courseModel.object(subject,@ioe['name'])
      ##puts @courseModel.model.predicates(@subjects,nil)
      #@triples = @courseModel.model.find(@subject, nil, nil)
      if params[:navigation] == nil
        render :layout => false
      end
    else
      render :nothing => true
    end
    
  end
  
  def delete
    
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ##puts "delete invoked"
    courseModel = Rdfmodel.new($courseFilename)
    courseModel.save_backup
    
    subject = courseModel.model.get_resource(params[:uri])
    type = courseModel.model.object(subject,rdf['type'])
    if type && type == ioe['Curriculum'] #if curriculum
      #first delete all semesters
      subject.get_properties(ioe['hasSem']) do |sem|
        semester = courseModel.model.get_resource(sem.uri.to_s)
        semester.delete_properties
        semester.object_of_predicate.each do |statement|
          courseModel.model.delete_statement(statement)     
        end
      end
    end #end if
    subject.delete_properties
    subject.object_of_predicate.each do |statement|
      courseModel.model.delete_statement(statement)     
    end
    
    courseModel.save
    redirect_to :action => 'view', :option => 'update'
    
    
  end
  
  def delete_curriculum_course
    courseModel = Rdfmodel.new($courseFilename)
    courseModel.save_backup
    dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    ##puts params[:semester]
    ##puts params[:course]
    semesterNode = Redland::Node.new(Redland::Uri.new(params[:semester]))
    courseNode = Redland::Node.new(Redland::Uri.new(params[:course]))
    courseModel.model.delete_statement(Redland::Statement.new(semesterNode, dcterms['hasPart'], courseNode))
    courseModel.model.delete_statement(Redland::Statement.new(courseNode, dcterms['isPartOf'], semesterNode))
    courseModel.save
    redirect_to :action => 'edit', :uri => params[:uri]
    
  end
  
  def update_form
    #puts "update_form"
    ioe=Redland::Namespace.new("http://ioe.edu.np/courseOnt#")    
    rdf=Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @names = []
    @uris = []
    @select = params[:type]
    @courseModel = Rdfmodel.new($courseFilename)
    if params[:type] == "Included in Course"  #course select
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Course'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }
    elsif params[:type] == "Includes Topics" || params[:type] == "Is Part of Topic" #topic select 
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Topic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
    elsif params[:type] == "Contains Topics" #subtopic select
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Subtopic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
      
    end
    render :layout => false
  end
  
  def update_data
    #puts "update invoked"
    nameModel = Rdfmodel.new($ontNames) 
    courseModel = Rdfmodel.new($courseFilename)
    courseModel.save_backup
    subject = courseModel.model.get_resource(params[:subject])
    predicate = Redland::Node.new(Redland::Uri.new(params[:predicate]))
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    reverse = nameModel.model.object(predicate, ioe['reverse'])
    if params[:objtype]=='NODE_TYPE_RESOURCE'        
      #puts params[:object]
      object = Redland::Node.new(Redland::Uri.new(params[:object]))        
      new_object = Redland::Node.new(Redland::Uri.new(params[:value])) if params[:value] != ""
    else
      object = Redland::Literal.new(params[:object])
      new_object = Redland::Literal.new(params[:value]) if params[:value] != ""
    end
    
    courseModel.model.delete_statement(Redland::Statement.new(subject, predicate, object))
    if reverse
      courseModel.model.delete_statement(Redland::Statement.new(object, reverse, subject))
    end
    if params[:value] != ""
      subject.add_property(predicate, new_object)
      if reverse
        courseModel.model.add_statement(Redland::Statement.new(new_object, reverse, subject))
      end
    end
    
    courseModel.save
    redirect_to :action => 'edit', :uri => params[:subject]
  end
  
  
  def edit
    if params[:uri] != "Select  Topic" &&  params[:uri] != "Select  Subtopic" && params[:uri] != "Select  Course" && params[:uri] != "Select  Curriculum" 
      ##puts params[:uri]
      @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
      @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
      @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
      
      @courseModel = Rdfmodel.new($courseFilename)
      @courseModel.uri = params[:uri]
      @nameModel = Rdfmodel.new($ontNames)
      
      
      @predicates = @courseModel.get_predicates
      @subject = @courseModel.model.get_resource(params[:uri])
      
      ##puts @courseModel.object(subject,@ioe['name'])
      ##puts @courseModel.model.predicates(@subjects,nil)
      #@triples = @courseModel.model.find(@subject, nil, nil)
      if params[:navigation] == nil
        render :layout => false
      end
    else
      render :nothing => true
    end
    
    
  end
  
  def add
    @courseModel = Rdfmodel.new($courseFilename)
    @courseModel.uri = params[:uri]
    @nameModel = Rdfmodel.new($ontNames)
    rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    subject = Redland::Node.new(Redland::Uri.new(params[:uri]))
    type = @courseModel.model.object(subject,rdf['type']).uri.to_s
    ##puts type
    ##puts ioe['Course'].uri.to_s
    @property_names = []
    @properties = []
    @property_uris = []
    @curriculum_select = false
    if type == ioe['Course'].uri.to_s
      @properties << dcterms['references']
      @properties << ioe['hasSchool']
      @properties << skos['narrower']
    elsif type == ioe['Topic'].uri.to_s     
      @properties << skos['broader']
      @properties << dcterms['hasPart']
    elsif type == ioe['Subtopic'].uri.to_s
      @properties << dcterms['isPartOf']
    elsif type == ioe['Curriculum'].uri.to_s
      curriculum = Curriculummodel.new();
      curriculum.uri = params[:uri]
      @courses, @coursenames = curriculum.getCourses
      @semesters =[]
      @semester_names = []
      @semesters, @semester_names = curriculum.get_semesters
      @curriculum_select = true
     
      
    end
    
    @properties.each { |property| 
      @property_names << @nameModel.model.object( property , ioe['label']).literal.value
      @property_uris << property.uri.to_s
    }
    ##puts @properties
    ##puts @property_names
    render :layout => false
  end
  
  def add_form
    rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @courseModel = Rdfmodel.new($courseFilename)
    @courseModel.uri = params[:uri]
    ##puts params[:uri]
    @nameModel = Rdfmodel.new($ontNames)
    @names = []
    @uris = []
    predicate = Redland::Node.new(Redland::Uri.new(params[:type]))
    @select = @nameModel.model.object(predicate, ioe['label']).literal.value
    @flag = 0
    if @select == "Included in Course"  #course select
      @flag =1
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Course'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }
    elsif @select == "Includes Topics" || @select == "Is Part of Topic" #topic select 
      @flag =1
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Topic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
    elsif @select == "Contains Topics" #subtopic select
      @flag =1
      nodes = @courseModel.model.subjects(rdf['type'], ioe['Subtopic'])
      nodes.each { |x| 
        @uris << x.uri.to_s
        @names << @courseModel.model.object(x, ioe['name']).literal.value
      }  
      
    end
    render :layout => false
  end 
  
  def add_operation
    nameModel = Rdfmodel.new($ontNames)
    ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    predicate = Redland::Node.new(Redland::Uri.new(params[:predicate]))
    select = nameModel.model.object(predicate, ioe['label']).literal.value
    
    courseModel = Rdfmodel.new($courseFilename)
    courseModel.save_backup
    
    subject = courseModel.model.get_resource(params[:subject])   
    if params[:objtype] == "Literal"
      object = Redland::Literal.new(params[:value]) 
      subject.add_property(predicate, object)
    else
      object = Redland::Node.new(Redland::Uri.new(params[:value]))
      subject.add_property(predicate, object)
      reverse = nameModel.model.object(predicate, ioe['reverse'])
      ##puts reverse
      if reverse
        courseModel.model.add_statement(Redland::Statement.new(object, reverse, subject))
      end
    end
    courseModel.save
    redirect_to :action => 'edit', :uri => params[:subject]
    
  end
  
  def search
    if params[:home]
      render :layout => false
    end
  end
  
  def advanced_search
    render :layout => false
  end
  
  def advanced_search_form
    render :layout => false
  end
  
  def perform_search
    @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @res = Courseaccessor.new($courseFilename)
    #@result = @res.advquery
    ##puts @result
    #render :text => "bhayooyoyooyyo"
    @titles = []
    @uris = []
    if params[:searchtype] == "simple"
      ##puts params[:search]
      @uris = @res.simple_query(params[:search])
    elsif params[:searchtype] == "advanced"
      @uris = @res.advquery(params[:option], params[:search] , params[:objectives], params[:references],
      params[:hoursLectureOperator], params[:hoursLecture],
      params[:hoursTutorialOperator], params[:hoursTutorial],
      params[:hoursLabOperator], params[:hoursLab],
      params[:hasSchool], params[:publisher],
      params[:hoursOperator], params[:hours],
      params[:shortDesc] )
      
      
      
    end
    @uris.each { |x| 
      uriNode = Redland::Node.new(Redland::Uri.new(x))
      @titles << @res.model.object(uriNode, @ioe['name']).literal.value
    }
    render :layout => false
  end
  
  def full_view
    @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @courseModel = Rdfmodel.new($courseFilename)
    courses = @courseModel.model.subjects(@rdf['type'], @ioe['Course'])
    ##puts courses
    @course_uris = []
    @course_names = []
    @topic_uris = []
    @topic_names = []
    @subtopic_names = []
    courses.each { |x| 
      @course_uris << x.uri.to_s
      @course_names << @courseModel.model.object(x, @ioe['name']).literal.value
    }
  end
  
  def view_all
    @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @courseModel = Rdfmodel.new($courseFilename)
    curriculums = @courseModel.model.subjects(@rdf['type'], @ioe['Curriculum'])
    @curriculum_uris = []
    @curriculum_names = []
    curriculums.each { |x| 
      @curriculum_uris << x.uri.to_s
      @curriculum_names << @courseModel.model.object(x, @ioe['name']).literal.value
    }
  end
  
  def navigate
    @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @courseModel = Rdfmodel.new($courseFilename)
    curriculums = @courseModel.model.subjects(@rdf['type'], @ioe['Curriculum'])
    @curriculum_uris = []
    @curriculum_names = []
    curriculums.each { |x| 
      @curriculum_uris << x.uri.to_s
      @curriculum_names << @courseModel.model.object(x, @ioe['name']).literal.value
    }
  end
  
  def navigateMenu
   if params[:uri] == "Select  Curriculum"
    render :nothing => true
   else
    @rdf= Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @ioe= Redland::Namespace.new("http://ioe.edu.np/courseOnt#")
    @skos= Redland::Namespace.new("http://www.w3.org/2004/02/skos/core#")
    @dcterms = Redland::Namespace.new("http://purl.org/dc/terms/")
    @courseModel = Rdfmodel.new($courseFilename)
    render :layout => false
   end
  end
end
