module ClassyBlog
	class Admin < Sinatra::Base
		use Rack::NoWWW

		set :public, 'public'
		set :views, File.join(File.dirname(__FILE__), 'views/admin')
		set :haml, :attr_wrapper => "\""

		def post_publishing_service

			@post_publishing_service ||= PostPublishingService.new

		end

		def post_querying_service

			@post_querying_service ||= PostQueryingService.new

		end

		before do

			@setting = Setting.first
			redirect(setup_link()) if @setting.nil?

			protected!

		end

		helpers do
			include SharedHelper
			include LinkHelper

			def authorized?

				return false unless @setting.login && @setting.password

				@auth ||= Rack::Auth::Basic::Request.new(request.env)

				@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials[0].eql?(@setting.login) && @auth.credentials[1].sha1.eql?(@setting.password)

			end

		end

		get "/?" do
			redirect setting_link()
		end

		get "/posts/new/?" do

			@post = Post.new(:published_at => Time.now.utc)
			haml :post

		end

		post "/posts/new/?" do

			@post = post_publishing_service.create(params[:title], params[:slug], params[:content], params[:published_at].empty? ? nil : Date.parse(params[:published_at]), params[:excerpt], params[:tags])

			if @post.errors.empty?
				redirect(posts_link())
			else
				haml :post
			end

		end

		get "/posts/edit/:id/?" do |id|

			id = get_id_or_throw_not_found_when_invalid(id);

			@post = post_querying_service.get_by_id(id)
			haml :post

		end

		post "/posts/edit/:id/?" do |id|

			id = get_id_or_throw_not_found_when_invalid(id);

			@post = post_publishing_service.update(id, params[:title], params[:slug], params[:content], params[:published_at].empty? ? nil : Date.parse(params[:published_at]), params[:excerpt], params[:tags])

			if @post.errors.empty?
				redirect(posts_link())
			else
				haml :post
			end

		end

		post "/posts/destroy/:id/?" do |id|

			id = get_id_or_throw_not_found_when_invalid(id);

			post_publishing_service.destroy(id)

			redirect(posts_link())

		end

		get "/posts/:page/?" do |page|

			page = get_page_or_throw_not_found_when_invalid(page)

			offset = start_index(page)

			@recents = Post.all(:published_at.not => nil, :order => [:published_at.desc], :offset => offset, :limit => @setting.items_per_page)
			@drafts = Post.all(:published_at => nil,:order => [:created_at.desc])

			count = Post.count(:published_at.not => nil)
			total_page = total_page(count)

			@next_link = posts_link(page + 1) if page < total_page
			@previous_link = posts_link(page -1) if page > 1

			haml :posts

		end

		get "/topics/?" do |page|
		end

		get "/setting/?" do

			@editSetting = Setting.first
			haml :setting

		end

		post "/setting/?" do

			@editSetting = Setting.first

			@editSetting.blog_title = params[:blog_title]
			@editSetting.tag_line = params[:tag_line]
			@editSetting.meta_keywords = params[:meta_keywords]
			@editSetting.meta_description = params[:meta_description]
			@editSetting.items_per_page = params[:items_per_page]
			@editSetting.posts_in_home = params[:posts_in_home]
			@editSetting.cache_duration_in_seconds = params[:cache_duration_in_seconds]

			@editSetting.login = params[:login]
			@editSetting.password = params[:password].sha1
			@editSetting.user_email = params[:user_email]
			@editSetting.user_full_name = params[:user_full_name]
			@editSetting.user_bio = params[:user_bio]

			@editSetting.aws_access_key_id = params[:aws_access_key_id]
			@editSetting.aws_secret_access_key = params[:aws_secret_access_key]
			@editSetting.aws_bucket = params[:aws_bucket]
			@editSetting.aws_cdn_prefix = params[:aws_cdn_prefix]

			@editSetting.google_analytics_code = params[:google_analytics_code]
			@editSetting.feed_burner_url = params[:feed_burner_url]

			@editSetting.bing_app_id = params[:bing_app_id]
			@editSetting.disqus_short_name = params[:disqus_short_name]
			@editSetting.typekit_code = params[:typekit_code]
			@editSetting.twitter_handle = params[:twitter_handle]

			if @editSetting.save()
				if defined?(CACHE)
					CACHE.delete('setting')
				end
				redirect(setting_link())
			else
				haml :setting
			end

		end

		private

		def protected!

			response['WWW-Authenticate'] = %(Basic realm="Administration") and \
			throw(:halt, [401, "Not authorized\n"]) and \
			return unless authorized?

		end

		def get_id_or_throw_not_found_when_invalid(id)

			number = safe_number(id)
			throw_not_found() unless number >= 1

			number

		end

	end
end
