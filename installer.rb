module ClassyBlog
	class Installer < Sinatra::Base
		use Rack::NoWWW

		set :public, 'public'
		set :views, File.join(File.dirname(__FILE__), 'views/installer')
		set :haml, :attr_wrapper => "\""

		helpers do
			include SharedHelper
			include LinkHelper

		end

		before do

			@editSetting = Setting.first
			redirect(home_link()) unless @editSetting.nil?

			@title = "#{ApplicationInfo::Name} : Setup"
			@editSetting = Setting.new

		end

		get "/?" do

			haml :setup

		end

		post "/?" do

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
				redirect(home_link())
			else
				haml :setup
			end

		end

	end
end
