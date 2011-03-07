require File.dirname(__FILE__)  + '/spec_helper.rb'
require File.dirname(__FILE__)  + '/../installer.rb'

module ClassyBlog

	describe Installer do
		include Rack::Test::Methods
		include SpecHelper

		context 'When setting does not exist' do

			def app
				Installer
			end

			it 'should render' do

				get '/'

				last_response.should be_ok
				last_response.body.should match(/<h1>#{ApplicationInfo::Name} : Setup<\/h1>/)

			end

		end

		context 'When setting exists' do

			def app
				Installer
			end

			before(:each) do
				enusure_setting
			end

			it 'should redirect to home' do
				get '/'
			end

			after(:each) do
				last_response.headers.should include('Location' => 'http://example.org/')
			end

		end

	end

end
