  require 'rubygems' 
  require'rdf/redland'
  
  
  $courseFilename = "db/data/courseStorage.rdf"
  $ontNames = "db/data/ontNames.rdf"
  $external_courses = "db/data/external_courses"


model=Redland::Model.new()
uri = Redland::Uri.new("file:"+ $courseFilename)
parser = Redland::Parser.new("rdfxml", "", nil)
parser.parse_into_model(model, uri)
backuppath = $courseFilename.gsub("db/data/", "db/data/backup/").insert(-5,"#{Time.now.strftime("%Y%m%d%H%M%S")}")
model.save(backuppath)

# load all courses from external courses directory 
Dir.entries($external_courses).select{|file_name| file_name =~ /\.rdf\z/}.each do |rdf_file|
  uri = Redland::Uri.new("file:"+ "#{$external_courses}/#{rdf_file}")  
  parser.parse_into_model(model, uri)
end

model.save($courseFilename)
