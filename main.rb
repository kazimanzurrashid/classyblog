require 'sinatra/content_for'
require 'json'
require 'pony'

module ClassyBlog
	class Main < Sinatra::Base
		use Rack::NoWWW

		set :public, 'public'
		set :haml, :attr_wrapper => "\""

		def tag_querying_service

			@tag_querying_service ||= TagQueryingService.new

		end

		def post_querying_service

			@post_querying_service ||= PostQueryingService.new

		end

		def page_querying_service

			@page_querying_service ||= PageQueryingService.new

		end

		def social_service

			@social_service ||= SocialService.new

		end

		helpers do
			include Sinatra::ContentFor
			include SharedHelper
			include LinkHelper

		end

		before do

			SETTING_CACHE_DURATION = 60 * 60 unless defined?(SETTING_CACHE_DURATION) # 1 Hour

			if defined?(CACHE)
				@setting = CACHE.fetch('setting', SETTING_CACHE_DURATION) { Setting.first }
			else
				@setting = Setting.first
			end

			redirect(setup_link()) if @setting.nil?

			TAGS_CACHE_DURATION = 60 * 30 unless defined?(TAGS_CACHE_DURATION) # Half an Hour

			if defined?(CACHE)
				@tags = CACHE.fetch('tags', TAGS_CACHE_DURATION) { tag_querying_service.find_published() }
			else
				@tags = tag_querying_service.find_published()
			end

			@feed_reader_count = 'N/A'
			@twitter_follower_count = 'N/A'

			SOCIAL_CACHE_DURATION = 60 * 60 * 6 unless defined?(SOCIAL_CACHE_DURATION) # 6 Hours

			unless @setting.feed_burner_url.blank?
				if defined?(CACHE)
					@feed_reader_count = CACHE.fetch('feed_burner_readers', SOCIAL_CACHE_DURATION) { social_service.feed_burner_reader_count(@setting.feed_burner_url) }
				else
					@feed_reader_count = social_service.feed_burner_reader_count(@setting.feed_burner_url)
				end
			end

			unless @setting.twitter_handle.blank?
				if defined?(CACHE)
					@twitter_follower_count = CACHE.fetch('twitter_followers', SOCIAL_CACHE_DURATION) { social_service.twitter_follower_count(@setting.twitter_handle) }
				else
					@twitter_follower_count = social_service.twitter_follower_count(@setting.twitter_handle)
				end
			end

		end

		after do

			set_cache()

		end

		get "/" do

			HOME_PAGE_POSTS_CACHE_DURATION = @setting.cache_duration_in_seconds * 3 # 3 Times of http cache

			count = @setting.posts_in_home + 1;

			if defined?(CACHE)
				@posts = CACHE.fetch('home_page_posts', HOME_PAGE_POSTS_CACHE_DURATION) { post_querying_service.find_recent(count) }
			else
				@posts = post_querying_service.find_recent(count)
			end

			if @posts.length == count
				# Ditch the last one
				@posts = @posts.slice!(0, @setting.posts_in_home) 
				haml :index
			else
				haml :posts
			end

		end

		get "/archive/:page/:year/:month/:day/" do |page, year, month, day|

			permanent_redirect(daily_archive_link(day, month, year, page))

		end

		get "/archive/:page/:year/:month/:day" do |page, year, month, day|

			page = get_page_or_throw_not_found_when_invalid(page)
			year, month, day = get_timeline_or_throw_not_found_when_invalid(year, month, day)

			count = post_querying_service.count_published_by_year_month_and_day(year, month, day)

			throw_not_found() unless count > 0

			offset = start_index(page)
			@posts = post_querying_service.find_published_by_year_month_and_day(year, month, day, offset, @setting.items_per_page)

			throw_not_found() unless @posts.length > 0

			@title = "#{Date::MONTHNAMES[month]} #{day}, #{year}"
			@sub_title = "Archive: #{Date::MONTHNAMES[month]} #{day}, #{year}"

			page_count = total_page(count)

			@next_link = daily_archive(day, month, year, page + 1) if page < page_count
			@previous_link = daily_archive(day, month, year, page -1) if page > 1

			haml :posts

		end

		get "/archive/:page/:year/:month/" do |page, year, month|

			permanent_redirect(monthly_archive_link(month, year, page))

		end

		get "/archive/:page/:year/:month" do |page, year, month|

			page = get_page_or_throw_not_found_when_invalid(page)
			year = get_year_or_throw_not_found_when_invalid(year)
			month = get_month_or_throw_not_found_when_invalid(month)

			count = post_querying_service.count_published_by_year_and_month(year, month)

			throw_not_found() unless count > 0

			offset = start_index(page)
			@posts = post_querying_service.find_published_by_year_and_month(year, month, offset, @setting.items_per_page)

			throw_not_found() unless @posts.length > 0

			@title = "#{Date::MONTHNAMES[month]}, #{year}"
			@sub_title = "Archive: #{Date::MONTHNAMES[month]}, #{year}"

			page_count = total_page(count)

			@next_link = monthly_archive(month, year, page + 1) if page < page_count
			@previous_link = monthly_archive(month, year, page - 1) if page > 1

			haml :posts

		end

		get "/archive/:page/:year/" do |page, year|

			permanent_redirect(yearly_archive_link(year, page))

		end

		get "/archive/:page/:year" do |page, year|

			page = get_page_or_throw_not_found_when_invalid(page)
			year = get_year_or_throw_not_found_when_invalid(year)

			count = post_querying_service.count_published_by_year(year)

			throw_not_found() unless count > 0

			offset = start_index(page)
			@posts = post_querying_service.find_published_by_year(year, offset, @setting.items_per_page)

			throw_not_found() unless @posts.length > 0

			@title = "#{year}"
			@sub_title = "Archive: #{year}"

			page_count = total_page(count)

			@next_link = yearly_archive(year, page + 1) if page < page_count
			@previous_link = yearly_archive(year, page - 1) if page > 1

			haml :posts

		end

		get "/archive/:page/" do |page|

			permanent_redirect(archive_link(safe_number(page)))

		end

		get "/archive/:page" do |page|

			page = get_page_or_throw_not_found_when_invalid(page)

			count = post_querying_service.count_published()

			throw_not_found() unless count > @setting.posts_in_home

			offset = start_index(page) + @setting.posts_in_home

			@posts = post_querying_service.find_published(offset, @setting.items_per_page)

			throw_not_found() unless @posts.length > 0

			page_count = total_page(count - @setting.posts_in_home)

			@next_link = archive(page + 1) if page < page_count
			@previous_link = archive(page - 1) if page > 1

			haml :posts

		end

		get "/archive/" do

			permanent_redirect(archive_link())

		end

		get "/archive" do

			@title = 'Archive'

			@posts = post_querying_service.find_recent(@setting.items_per_page)
			@archives = post_querying_service.find_archives()

			haml :archive

		end

		get "/topics/:slug/:page/" do |slug, page|

			permanent_redirect(tag_link(slug, page))

		end

		get "/topics/:slug/:page" do |slug, page|

			page = get_page_or_throw_not_found_when_invalid(page)

			tag = tag_querying_service.get_by_slug(slug)

			throw_not_found() unless tag

			count = post_querying_service.count_published_by_tag(tag.id)

			throw_not_found() unless count > 0

			offset = start_index(page)
			@posts = post_querying_service.find_published_by_tag(tag.id, offset, @setting.items_per_page)

			throw_not_found() unless @posts.length > 0

			@title = @sub_title = "Topic: #{tag.title}"

			page_count = total_page(count)

			@next_link = tag_link(slug, page + 1) if page < page_count
			@previous_link = tag_link(slug, page - 1) if page > 1

			haml :posts

		end

		get "/search/?" do

			throw_not_found() if @setting.bing_app_id.blank?

			query = params[:q]

			throw_not_found() if query.blank?

			page = get_page_or_throw_not_found_when_invalid(params[:page])
			offset = start_index(page)

			host = root()
			query_which_only_includes_root = URI.escape("#{query} site:#{host}")
			end_point = "http://api.bing.net/json.aspx?Sources=Web&Version=2.0&Market=en-us&Adult=Moderate&AppId=#{@setting.bing_app_id}&Query=#{query_which_only_includes_root}&Web.Count=#{@setting.items_per_page}&Web.Offset=#{offset}&JsonType=raw"

			@title = @sub_title = "Search: #{h(query)}"

			begin

				response = Net::HTTP.get(URI.parse(end_point))
				result = JSON.parse(response)

				count = result['SearchResponse']['Web']['Total']
				page_count = total_page(count)

				@posts = result['SearchResponse']['Web']['Results'] || []

				escaped_query = URI.escape(query)
				@next_link = "/search?q=#{escaped_query}&page=#{page + 1}" if page < page_count
				@previous_link = "/search?q=#{escaped_query}&page=#{page - 1}" if page > 1

			rescue
				@error_message = 'An unexpected error has occurred while searching. Though it may sound odd but looks like <a href="http://www.bing.com/">Bing</a> which is used to search this site is down.'
			end

			haml :search

		end

		get "/contact/" do

			permanent_redirect(contact_link())

		end

		get "/contact" do

			throw_not_found() if @setting.user_email.blank?

			@title = 'Contact'
			@contact = Contact.new

			haml :contact

		end

		post "/contact" do

			throw_not_found() if @setting.user_email.blank?

			@contact = Contact.new
			@contact.name = params[:name]
			@contact.email = params[:email]
			@contact.subject = params[:subject]
			@contact.message = params[:message]

			if @contact.valid?
				begin
					Pony.mail(:to => @setting.user_email, :from => "\"#{@contact.name}\" <#{@contact.email}>", :subject => @contact.subject, :body => @contact.message, :via => :smtp, :via_options => { :address => 'smtp.sendgrid.net', :authentication => :plain, :port => '25', :user_name => ENV['SENDGRID_USERNAME'], :password => ENV['SENDGRID_PASSWORD'], :domain => ENV['SENDGRID_DOMAIN']})

					@success_message = 'Your message has been sent.'
					@contact = Contact.new # reset the values
				rescue
					@error_message = 'An unexpected error has occurred while sending your message. Please make sure you have typed a valid email address.'
				end
			end

			@title = 'Contact'
			haml :contact

		end

		get "/posts/:slug/" do |slug|

			permanent_redirect(post_link(slug))

		end

		get "/posts/:slug" do |slug|

			@post = post_querying_service.get_published_by_slug(slug)

			throw_not_found() if @post.nil?

			@title = @post.title

			haml :post

		end

		get "/feed/" do

			permanent_redirect(feed_link())

		end

		get "/feed" do

			@posts = post_querying_service.find_recent(@setting.items_per_page)

			content_type 'application/atom+xml', :charset => 'utf-8'

			haml :atom, :layout => false

		end

		get "/:slug/" do |slug|

			permanent_redirect(page_link(slug))

		end

		get "/:slug" do |slug|

			@page = page_querying_service.get_published_by_slug(slug)

			throw_not_found() if @page.nil?

			@title = @page.title

			haml :page

		end

		private

		def permanent_redirect(url)

			redirect(url, 301)

		end

		def get_year_or_throw_not_found_when_invalid(year)

			number = safe_number(year)
			throw_not_found() unless number >= 1990

			number

		end

		def get_month_or_throw_not_found_when_invalid(month)

			number = safe_number(month)
			throw_not_found() unless number >= 1 && number <= 12

			number

		end

		def get_timeline_or_throw_not_found_when_invalid(year, month, day)

			safe_year = get_year_or_throw_not_found_when_invalid(year)
			safe_month = get_month_or_throw_not_found_when_invalid(month)
			safe_day = safe_number(day)

			throw_not_found() unless safe_day >= 1 && safe_day <= Date.days_in_month(safe_year, safe_month)

			[safe_year, safe_month, safe_day]

		end

	end

end
