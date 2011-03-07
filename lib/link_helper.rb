module ClassyBlog
	module LinkHelper

		def root()
			"#{request.scheme}://#{request.host}#{request.port == 80 ? '' : ":#{request.port}"}"
		end

		def absolute(relative_url)
			root() + (relative_url[0, 1] == '/' ? relative_url : '/' + relative_url)
		end

		def home_link()
			'/'
		end

		def setup_link()
			'/setup'
		end

		def feed_link()
			'/feed'
		end

		def css_link(file)

			if production?
				if defined?(@setting) && !@setting.aws_cdn_prefix.blank?
					return "#{request.scheme}://#{@setting.aws_cdn_prefix}.#{request.host}/#{ApplicationInfo::Version}/styles/#{file}.min.css"
				elsif defined?(@setting) && !@setting.aws_bucket.blank?
					return "#{request.scheme}://assets.#{@setting.aws_bucket}.s3.amazonaws.com/#{ApplicationInfo::Version}/styles/#{file}.min.css"
				end
			end
			
			"/assets/styles/#{file}.css"

		end

		def js_link(file)

			if production?
				if defined?(@setting) && !@setting.aws_cdn_prefix.blank?
					return "#{request.scheme}://#{@setting.aws_cdn_prefix}.#{request.host}/#{ApplicationInfo::Version}/scripts/#{file}.min.js"
				elsif defined?(@setting) && !@setting.aws_bucket.blank?
					return "#{request.scheme}://assets.#{@setting.aws_bucket}.s3.amazonaws.com/#{ApplicationInfo::Version}/scripts/#{file}.min.js"
				end
			end

			"/assets/scripts/#{file}.js"

		end

		def image_link(file)

			if production?
				if defined?(@setting) && !@setting.aws_cdn_prefix.blank?
					return "#{request.scheme}://#{@setting.aws_cdn_prefix}.#{request.host}/#{ApplicationInfo::Version}/images/#{file}"
				elsif defined?(@setting) && !@setting.aws_bucket.blank?
					return "#{request.scheme}://assets.#{@setting.aws_bucket}.s3.amazonaws.com/#{ApplicationInfo::Version}/images/#{file}"
				end
			end

			"/assets/images/#{file}"

		end

		def meta_web_log_link()
			'/api/metaweblog.xml'
		end

		def rsd_link()
			'/api/rsd.xml'
		end

		def wlwmanifest_link()
			'/api/wlwmanifest.xml'
		end

		def public_feed_link()
			@setting.feed_burner_url.blank? ? private_feed_link() : @setting.feed_burner_url
		end

		def private_feed_link()
			'/feed'
		end

		def contact_link()
			'/contact'
		end

		def search_link()
			'/search'
		end

		def archive_link(page = 0)
			page > 0 ? "/archive/#{page}" : '/archive'
		end

		def daily_archive_link(day, month, year, page = 1)
			"/archive/#{page}/#{year}/#{month}/#{day}"
		end

		def monthly_archive_link(month, year, page = 1)
			"/archive/#{page}/#{year}/#{month}"
		end

		def yearly_archive_link(year, page = 1)
			"/archive/#{page}/#{year}"
		end

		def tag_link(slug, page = 1)
			"/topics/#{slug}/#{page}"
		end

		def post_link(slug)
			"/posts/#{slug}"
		end

		def page_link(slug)
			"/#{slug}"
		end

		def admin_link()
			'/admin'
		end

		def setting_link()
			'/admin/setting'
		end

		def posts_link(page = 1)
			"/admin/posts/#{page}"
		end

		def new_post_link()
			'/admin/posts/new'
		end
	
		def edit_post_link(id)
			"/admin/posts/edit/#{id}"
		end
	
		def pages_link(page = 1)
			"/admin/pages/#{page}"
		end

		def new_page_link()
			'/admin/pages/new'
		end
	
		def edit_page_link(id)
			"/admin/pages/edit/#{id}"
		end

		def tags_link()
			'/admin/topics'
		end

	end
end
