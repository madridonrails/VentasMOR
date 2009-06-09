module ApplicationConfiguration
  # see http://kpumuk.info/ruby-on-rails/flexible-application-configuration-in-ruby-on-rails/
  #     http://en.wikipedia.org/wiki/YAML
  require 'ostruct'
  require 'yaml'
  ::Config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/application.yml"))
end