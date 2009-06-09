require 'test/unit'
require 'yaml'

RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../../') unless defined? RAILS_ROOT

class ApplicationConfigurationTest < Test::Unit::TestCase
  
  def test_presence_of_application_yml_file
    assert  File.exist?("#{RAILS_ROOT}/config/application.yml"), "File application.yml does not exist in config folder"
  end
  
  def test_format_of_application_yml
    assert_nothing_raised do 
      begin
        YAML.load_file("#{RAILS_ROOT}/config/application.yml")
      rescue Errno::ENOENT
        flunk "Could not load application.yml from /config folder"
      rescue ArgumentError
        flunk "/config/application.yml has bad format!"
      end
    end
  end
  
  def test_parsing_of_example_yaml_file
    assert_equal "Ruby", YAML.load_file(
                          File.join(File.dirname(__FILE__), '../', 'resources', 'application.yml') 
                        )['topics'][0]
  end
  
end
