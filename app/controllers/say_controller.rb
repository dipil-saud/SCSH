class SayController < ApplicationController
  
  
  attr_accessor :endpoints
  attr_accessor :resources
  attr_accessor :book_result
  attr_accessor :article_result
  attr_accessor :article_endpoint
  attr_accessor :fact_endpoint
  attr_accessor :resourceFactory
  
  
  def initialize  
    super 
    self.book_result = Hash.new
    self.article_result = Hash.new
    self.endpoints = []
    self.resources = []
    dblp = Endpointa.new("dblp")
    self.endpoints << dblp
    
    self.article_endpoint = []
    eprint = Endpointa.new("eprint")
    self.article_endpoint<<eprint
  
  self.fact_endpoint = []
  dbpedia = Facts_endpoint.new("dbpedia")
  self.fact_endpoint<<dbpedia
  
  self.resourceFactory = Resource_factory.new
  
end


def hello
  
  @title = []
  @uri = []
  if params[:search] != nil && params[:search].length >0
  @search_phrase = params[:search]
  
  @option = 1

  if @option == 1
      if params[:courseSearch]
        #puts "courseSearch"
        advanced_endpoint = Endpoint_advanced.new("as") 
        title_array =[]
        uri_array = []
        title_array, uri_array = advanced_endpoint.courseQuery(params[:uri])
        @title.concat(title_array)
        @uri.concat(uri_array)
      else
        self.endpoints.each{ |endpoint|                         
                          title_array, uri_array = endpoint.query(@search_phrase) 
                          self.book_result = { "title" => title_array, "uri" => uri_array}
                          @title = title_array
                          @uri = uri_array
                      
                        }
      end
   elsif @option == 2
     self.fact_endpoint.each{|endpoint|
                         title_array,uri_array= endpoint.query(@search_phrase)
                         @title = title_array
                         @uri1 = uri_array
                         }
  end
end
  
  end 

  def generate_content
    
    #puts "generate_content"
    
    
    @title = []
    @uri = []
    @uri1 = []
    if params[:search]
    search_phrase = params[:search]
    if params[:type] == "Book"
      self.endpoints.each{ |endpoint| 
                        if self.book_result.empty?
                        title_array, uri_array = endpoint.query(search_phrase) 
                        self.book_result = { "title" => title_array, "uri" => uri_array}
                        @title = title_array
                        @uri = uri_array
                        else
                        @title = self.book_result["title"]
                        @uri = self.book_result["uri"]
                       end                     
                     } #end if book

        #@title = ["Book"]
        #@uri = ["http://dblp.l3s.de/d2r/resource/publications/books/acm/Kim95"]
    elsif params[:type] == "Article"
    
    
      self.article_endpoint.each{|endpoint|
                         title_array,uri_array= endpoint.query(search_phrase)
                         @title = title_array
                         @uri = uri_array
                         }
                         ##puts @title
                        #puts @uri

    elsif params[:type] == "Twitter"
          #puts "twitter"
          twitter_test = Twittertest.new
   status_array,statcreated_array = twitter_test.query(search_phrase)
    @status = status_array
    @status_created = statcreated_array
    
 
   
    
   elsif params[:type] == "Fact"
            self.fact_endpoint.each{|endpoint|
                         title_array,uri_array= endpoint.query(search_phrase)
                         @title = title_array
                         @uri1 = uri_array
                         }
            
   end
  end
  render :layout =>false
   
 end
 
 def ad_article
   @title=[]
   @uri=[]
  
  title_phrase=""
   author_phrase = ""
  journal_phrase = ""
 
  @author = []
  @journal = []
  
   if params[:title] != nil && params[:title].length >0
   title_phrase = params[:title]
    @title = 1
  end

  if params[:author] != nil && params[:author].length >0
    author_phrase = params[:author]
    @author = 1
  end
   if params[:journal] != nil && params[:journal].length >0
    journal_phrase = params[:journal]
    @journal = 1
  end
  
  if @title==1||@author==1||@journal==1
  advanced_endpoint = Endpoint_adarticle.new("as") 
  title_array,uri_array =advanced_endpoint.query2( title_phrase, author_phrase, journal_phrase)
      @title = title_array
  @uri = uri_array
  
 end

 end
 
 def advanced_search
  @title=[]
  @uri=[]
  publisher_array = []
  title_phrase = ""
  publisher_phrase=""
  date_phrase_a = ""
  date_phrase_b = ""
  chapter_phrase = ""
  @publisher = []
  @date = []
  @chapter = []
  @page = []
  @ch_uri = []
  if params[:title] != nil && params[:title].length >0
    #@publisher_phrase = params[:publisher]
    title_phrase = params[:title]
    @title11 = 1
  end
   if params[:publisher] != nil && params[:publisher].length >0
    #@publisher_phrase = params[:publisher]
    publisher_phrase = params[:publisher]
    @publisher = 1
  end

  if params[:date_b] != nil && params[:date_b].length >0
    #@date_phrase = params[:date]
    date_phrase_b = params[:date_b]
    @date_b = 1
  end
  if params[:date_a] != nil && params[:date_a].length >0
    #@date_phrase = params[:date_a]
    date_phrase_a = params[:date_a]
    @date_a = 1
  end
  
  if params[:chapter] != nil && params[:chapter].length >0
    #@chapter_phrase = params[:chapter]
    chapter_phrase = params[:chapter]
    @chapter = 1
  end
  
  if @publisher==1||@date_b==1||@date_a==1||@chapter==1||@title11==1
  advanced_endpoint = Endpoint_advanced.new("as") 
  title_array,uri_array,publisher_array, date_array,chapter_array,ch_uri_array, page_array = advanced_endpoint.query2(  title_phrase, publisher_phrase, date_phrase_a,date_phrase_b, chapter_phrase)
      @title = title_array
  @uri = uri_array
  @publisher = publisher_array
  @date = date_array
  @chapter = chapter_array
  @page = page_array
  @ch_uri = ch_uri_array
 end

end

end
