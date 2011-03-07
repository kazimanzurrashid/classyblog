require 'rubygems' if RUBY_VERSION < '1.9'
require 'digest/sha1'
require 'net/http'
require 'uri'
require 'rack/no-www'
require 'sinatra'
require 'sinatra/base'
require 'haml'
root_location = File.join(File.dirname(__FILE__))
lib_location = File.join(root_location, 'lib')
require File.join(lib_location, 'cache_manager.rb')
require File.join(lib_location, 'extensions.rb')
require File.join(lib_location, 'application_info.rb')
require File.join(lib_location, 'shared_helper.rb')
require File.join(lib_location, 'link_helper.rb')
require File.join(lib_location, 'tag_querying_service.rb')
require File.join(lib_location, 'page_querying_service.rb')
require File.join(lib_location, 'post_querying_service.rb')
require File.join(lib_location, 'page_publishing_service.rb')
require File.join(lib_location, 'post_publishing_service.rb')
require File.join(lib_location, 'social_service.rb')
require File.join(root_location, 'models.rb')
