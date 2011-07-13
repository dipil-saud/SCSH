class Googlesearch2
  
require 'rubygems'
require 'open-uri'
require 'rexml/document'
require 'cgi'
require 'json'
require 'pp'

  ##
  # :singleton-method: web(options)
  
  ## 
  # :singleton-method: video(options)
  
  ##
  # :singleton-method: blogs(options)

  ##
  # :singleton-method: news(options)

  ##
  # :singleton-method: books(options)

  ##
  # :singleton-method: images(options)

  ##
  # :singleton-method: patent(options)
  class << self
    ##
    # :singleton-method:
    # Default options that should be present in every request
    def default_options
      @default_options ||= {}
    end

    ##
    # :singleton-method:
    # Sets up default options that should be present in every request
    def default_options=(options)
      @default_options = options
    end

    def method_missing(method, args) # :nodoc:
      raise "Unknown search type '#{method}'" unless supported_search_types.include?(method)
      query(method, args)
    end
   
    # Yields the search method for number +pages+ specified.
    # Each page will contain 8 results, +pages+ must be something enumerable
    def with_pages(pages)
      orig_options = default_options.clone 
      pages.each do |page|
        default_options.merge!(:rsz => "large", :start => (page - 1) * 8)
        yield
      end
      default_options = orig_options
    end

    private
      def supported_search_types
        [:web, :local, :video, :blogs, :news, :books, :images, :patent]
      end
        
      def query(type, options)
        options = default_options.merge(options)
        options[:v] = "1.0"
        options[:rsz] = "large"
        options [:start] = 9
        query_string = options.collect { |key, value| "#{key}=#{CGI::escape(value.to_s)}" }.join("&")
        uri = "http://ajax.googleapis.com/ajax/services/search/#{type}?#{query_string}"
        #puts uri            
        result = JSON.parse(open(uri).read)
        raise GoogleSearchError, "#{result['responseStatus']} - #{result['responseDetails']}" unless result["responseStatus"] == 200
        
        result
      end
  end
end