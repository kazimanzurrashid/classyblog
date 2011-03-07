require File.dirname(__FILE__)  + '/../dependencies.rb'
require 'rspec'
require 'rack/test'
require 'dm-migrations'

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

DataMapper.setup(:default, "sqlite3::memory:")

Rspec.configure do |config|
	config.before(:each) { DataMapper.auto_migrate! }
end

module ClassyBlog
	module SpecHelper

		def enusure_setting

			Setting.destroy

			setting = Setting.new

			setting.blog_title = 'Test Blog'
			setting.login = 'test'
			setting.password = 'test'.sha1
			setting.user_full_name = 'test user'
			setting.user_email = 'testuser@testdomain.com'

			setting.save

		end

	end
end
