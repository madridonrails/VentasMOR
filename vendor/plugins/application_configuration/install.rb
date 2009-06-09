require 'ftools'

RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../') unless defined? RAILS_ROOT

# Copy example application.yml to RAILS_ROOT/config
unless File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
  if File.cp( 
    File.join(File.dirname(__FILE__), 'resources', 'application.yml'), 
    File.join(RAILS_ROOT, 'config')
    )
    puts "Application Configuration Plugin:\n- File application.yml succesfully copied to /config folder"
  else
    raise "PluginInstallError (Could not copy file application.yml to /config folder)"
  end
else
  puts "Application Configuration Plugin:\n[!] File application.yml exists in /config folder -- not copied."
end

# Show the README text file
puts "\n\n"
puts IO.read(File.join(File.dirname(__FILE__), 'README'))