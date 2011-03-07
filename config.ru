require 'dependencies.rb'
require 'installer.rb'
require 'admin.rb'
require 'api.rb'
require 'main.rb'

#set :environment, :development
set :environment, :production

configure :production do
	require 'newrelic_rpm'
end

map '/setup' do
	run ClassyBlog::Installer
end

map '/api' do
	run ClassyBlog::Api
end

map '/admin' do
	run ClassyBlog::Admin
end

map '/' do
	run ClassyBlog::Main
end
