require File.dirname(__FILE__)  + '/spec_helper.rb'
require File.dirname(__FILE__)  + '/../main.rb'

module ClassyBlog

	describe Main do
		include Rack::Test::Methods
		include SpecHelper

		context 'When setting exists' do

			def app
				Main
			end

			before(:each) do

				enusure_setting
				Tag.destroy
				Post.destroy

			end

			it 'should render home' do

				get '/'

				last_response.should be_ok

			end

			it 'should redirect when archive day has trailing slash for archive with page number, year, month and day' do

				get '/archive/1/2010/12/31/'

				last_response.headers.should include('Location' => 'http://example.org/archive/1/2010/12/31')

			end

			it 'should return 404 when page number is invalid for archive with page number, year, month and day' do

				get '/archive/-1/2010/12/31'

				last_response.status.should == 404

			end

			it 'should return 404 when year is less than 1990 for archive with page number, year, month and day' do

				get '/archive/1/1989/12/31'

				last_response.status.should == 404

			end

			it 'should return 404 when month is not between 1 to 12 for archive with page number, year, month and day' do

				get '/archive/1/1990/13/31'

				last_response.status.should == 404

			end

			it 'should return 404 when day is not valid for archive with page number, year, month and day' do

				get '/archive/1/1991/02/29'

				last_response.status.should == 404

			end

			it 'should return 404 when posts are empty for archive with page number, year, month and day' do

				get '/archive/1/2010/11/29'

				last_response.status.should == 404

			end

			it 'should render archive with page number, year, month and day' do

				now = Time.now.utc

				create_post 10, now

				get "/archive/1/#{now.year}/#{now.month}/#{now.day}"

				last_response.should be_ok

			end

			it 'should redirect when archive month has trailing slash for archive with page number, year and month' do

				get '/archive/1/2010/12/'

				last_response.headers.should include('Location' => 'http://example.org/archive/1/2010/12')

			end

			it 'should return 404 when page number is invalid for archive with page number, year and month' do

				get '/archive/-1/2010/12'

				last_response.status.should == 404

			end

			it 'should return 404 when year is less than 1990 for archive with page number, year and month' do

				get '/archive/1/1989/12'

				last_response.status.should == 404

			end

			it 'should return 404 when month is not between 1 to 12 for archive with page number, year and month' do

				get '/archive/1/1990/13'

				last_response.status.should == 404

			end

			it 'should return 404 when posts are empty for archive with page number, year and month' do

				get '/archive/1/2010/11'

				last_response.status.should == 404

			end

			it 'should render archive with page number, year and month' do

				now = Time.now.utc

				create_post 10, now

				get "/archive/1/#{now.year}/#{now.month}"

				last_response.should be_ok

			end

			it 'should redirect when archive year has trailing slash for archive with page number and year' do

				get '/archive/1/2010/'

				last_response.headers.should include('Location' => 'http://example.org/archive/1/2010')

			end

			it 'should return 404 when page number is invalid for archive with page number and year' do

				get '/archive/-1/2010'

				last_response.status.should == 404

			end

			it 'should return 404 when year is less than 1990 for archive with page number and year' do

				get '/archive/1/1989'

				last_response.status.should == 404

			end

			it 'should return 404 when posts are empty for archive with page number and year' do

				get '/archive/1/2010'

				last_response.status.should == 404

			end

			it 'should render archive with page number and year' do

				now = Time.now.utc

				create_post 10, now

				get "/archive/1/#{now.year}"

				last_response.should be_ok

			end

			it 'should redirect when archive page number has trailing slash for archive with page number' do

				get '/archive/1/'

				last_response.headers.should include('Location' => 'http://example.org/archive/1')

			end

			it 'should return 404 when page number is invalid for archive with page number' do

				get '/archive/-1'

				last_response.status.should == 404

			end

			it 'should return 404 when posts are empty for archive with page number' do

				get '/archive/1'

				last_response.status.should == 404

			end

			it 'should render archive with page number' do

				create_post 15, Time.now.utc

				get '/archive/1'

				last_response.should be_ok

			end

			it 'should redirect when archive has trailing slash' do

				get '/archive/'

				last_response.headers.should include('Location' => 'http://example.org/archive')

			end

			it 'should render archive' do

				get '/archive'

				last_response.should be_ok

			end

			it 'should redirect when topics page number has trailing slash' do

				get '/topics/html5/1/'

				last_response.headers.should include('Location' => 'http://example.org/topics/html5/1')

			end

			it 'should return 404 when page number is invalid for topic with page number' do

				get '/topics/html5/-1'

				last_response.status.should == 404

			end

			it 'should return 404 when topic does not exist' do

				get '/topics/html5/1'

				last_response.status.should == 404

			end

			it 'should return 404 when posts are empty for topic with page number' do

				Tag.new(:title => 'Html5', :slug => 'html5').save

				get '/topics/html5/1'

				last_response.status.should == 404

			end

			it 'should render topic with page number' do

				tag = Tag.new(:title => 'Html5', :slug => 'html5')
				post = Post.new(:title => 'Dummy Post', :slug => 'dummy-post', :content => 'Post Body', :created_at => Time.now.utc, :published_at => Time.now.utc)
				post.tags << tag
				post.save

				get '/topics/html5/1'

				last_response.should be_ok

			end

			it 'should redirect when contact has trailing slash' do

				get '/contact/'

				last_response.headers.should include('Location' => 'http://example.org/contact')

			end

			it 'should render contact' do

				get '/contact'

				last_response.should be_ok

			end

		end

		context 'When setting does not exist' do

			def app
				Main
			end

			it 'should redirect to setup' do
				get '/'
			end

			after(:each) do
				last_response.headers.should include('Location' => 'http://example.org/setup')
			end

		end

		def create_post(number_of, time)

			number_of.times do |num|
				Post.new(:title => "Dummy Post #{num}", :slug => "dummy-post-#{num}", :content => "Post Body #{num}", :created_at => time, :published_at => time).save
			end

		end

	end

end
