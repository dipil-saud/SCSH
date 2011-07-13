class ResourceManagerController < ApplicationController
  
  attr_accessor :books
  attr_accessor :articles
  attr_accessor :projects
  attr_accessor :facts
  attr_accessor :resourceFactory
  
  def initialize
    self.books = []
    self.articles = []
    self.projects = []
    self.facts = []
    self.resourceFactory = Resource_factory.new    
  end
  
  def new_resource
    
    if params[:type] == "Book"||params[:type] == "Article"||params[:type] == "Fact"
    #puts params[:uri]
    #puts params[:type]
    @newresource = self.resourceFactory.create_resource(params[:type], params[:uri])
      books << @newresource
    else
       @newresource = self.resourceFactory.twitter_resource(params[:date], params[:status])
    end
 render "#{params[:type]}display", :layout => false
      #puts @newresource.title
   
  end

end
