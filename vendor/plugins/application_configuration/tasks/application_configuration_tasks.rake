namespace :application_configuration do
  
  desc "Install the plugin"
  task :install do
    puts "\nInstalling the Application Configuration plugin\n-----------------------------------------------"
    require File.join(File.dirname(__FILE__), '../', 'install.rb')
  end
  
  desc "Uninstall the plugin"
  task :uninstall do
    puts "\nUninstalling the Application Configuration plugin\n-----------------------------------------------"
    require File.join(File.dirname(__FILE__), '../', 'uninstall.rb')
  end
  
end