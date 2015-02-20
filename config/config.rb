require 'yaml'
require 'erb'

module Configuration
  def self.load_config
    config_file = 'config/config.yml.erb'
    config_file_erb = ERB.new(File.read(config_file)).result
    File.exist?(config_file) ? YAML.load(config_file_erb)[ENV['APP_ENV']] : {}
  end
end
