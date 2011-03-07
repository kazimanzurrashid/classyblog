require File.dirname(__FILE__)  + '/spec_helper.rb'
require File.dirname(__FILE__)  + '/../api.rb'

module ClassyBlog

	describe Api do
		include Rack::Test::Methods
		include SpecHelper

		context 'When setting exists' do

			def app
				Api
			end

			before(:each) do
				enusure_setting
			end

			it 'should render sitemap.xml' do

				get '/sitemap.xml'

				last_response.should be_ok
				last_response.headers['Content-Type'].should == 'text/xml;charset=utf-8'
				last_response.body.should match(/<urlset xmlns="http:\/\/www.sitemaps.org\/schemas\/sitemap\/0.9">/)

			end

			it 'should render rsd.xml' do

				get '/rsd.xml'

				last_response.should be_ok
				last_response.headers['Content-Type'].should == 'application/rsd+xml;charset=utf-8'
				last_response.body.should match(/<rsd version="1.0">/)

			end

			it 'should render wlwmanifest.xml' do

				get '/wlwmanifest.xml'

				last_response.should be_ok
				last_response.headers['Content-Type'].should == 'application/wlwmanifest+xml;charset=utf-8'
				last_response.body.should match(/<manifest xmlns="http:\/\/schemas.microsoft.com\/wlw\/manifest\/weblog">/)

			end

			it 'should only support metaweblog.xml in post' do

				get '/metaweblog.xml'

				last_response.status.should == 404

			end

		end

		context 'When setting does not exist' do

			def app
				Api
			end

			it 'should redirect to setup' do
				get '/'
			end

			after(:each) do
				last_response.headers.should include('Location' => 'http://example.org/setup')
			end

		end

	end

end
