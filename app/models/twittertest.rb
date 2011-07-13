class Twittertest
  
require 'rubygems'
require 'twitter'


def initialize 
end

def query(search_phrase)
   #puts search_phrase
   status_created = []
   statuses =[]
   stat_created = ""
 
  Twitter::Client.configure do |conf|
  conf.oauth_consumer_token = 'asw05JUJT9v8aOf7z6EuA'
  conf.oauth_consumer_secret = 'qps5QCTeHHDvv29PruerINO8Tpzf54cTDNDiA2nhpk'
  
   client = Twitter::Client.new(:oauth_access => { 
  :key => 'JDoFdGfJvdeVaETafUAkJz64fVLzCU05yvrwHkPB8', :secret => 'qps5QCTeHHDvv29PruerINO8Tpzf54cTDNDiA2nhpk' })
# below returns 10 results per page, and just the first page (by default), for tweets containing "searchterm".
  statuses = client.search(:q => search_phrase,:show_user => 1, :rpp => 300)
#trim_user=true

  end

  statuses.each do |stat|
    # jpt #puts "#{statuses.user.screen_name}: #{statuses.text} @ #{statuses.created_at}"
  ##puts stat.screen_name
     stat_created = stat.created_at
     status_created<<stat_created
   
 end
 
 return statuses,status_created
end


end

