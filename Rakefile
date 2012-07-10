# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "gcm_on_rails"
  gem.homepage = "http://github.com/dondeng/gcm_on_rails"
  gem.license = "MIT"
  gem.summary = %Q{Google Cloud Messaging for Android on Rails}
  gem.description = %Q{gcm_on_rails is a Ruby on Rails gem that allows you to easily incorporate Google's
                    'Google Cloud Messaging for Android' into your Rails application. This gem was derived from
                    c2dm_on_rails (https://github.com/pimeys/c2dm_on_rails) after Google deprecated C2DM on June 27, 2012}
  gem.email = "dondeng2@gmail.com"
  gem.authors = ["Dennis Ondeng"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gcm_on_rails #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


task :default => :spec