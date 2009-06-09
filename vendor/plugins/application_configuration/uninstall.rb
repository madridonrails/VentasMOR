require 'ftools'

if File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
  File.delete( File.join(RAILS_ROOT, 'config', 'application.yml') )
  puts "Removed file config/application.yml"
end