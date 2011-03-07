require 'xmlrpc/marshal'
require 'aws/s3'

module ClassyBlog
	class Api < Sinatra::Base
		use Rack::NoWWW

		set :views, File.join(File.dirname(__FILE__), 'views/api')
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

		def post_publishing_service

			@post_publishing_service ||= PostPublishingService.new

		end

		def page_publishing_service

			@page_publishing_service ||= PagePublishingService.new

		end

		helpers do
			include SharedHelper
			include LinkHelper

		end

		before do

			@setting = Setting.first
			redirect(setup_link()) if @setting.nil?

		end
 
		get "/sitemap.xml" do

			set_cache()

			@posts = post_querying_service.find_recent(@setting.items_per_page)
			@pages = page_querying_service.find_published()
			@tags = tag_querying_service.find_published()
			@archives = post_querying_service.find_archives()

			content_type('text/xml', :charset => 'utf-8')
			haml :sitemap

		end

		get "/rsd.xml" do

			set_cache()

			content_type('application/rsd+xml', :charset => 'utf-8')
			haml :rsd

		end

		get "/wlwmanifest.xml" do

			set_cache()

			content_type('application/wlwmanifest+xml', :charset => 'utf-8')
			haml :wlwmanifest

		end

		post "/metaweblog.xml" do

			xml = request.body.read

			command = XMLRPC::Marshal.load_call(xml)

			# remove the known prefixes and put underscore at each word to follow the ruby method naming convention
			method = command[0].gsub(/(metaweblog|blogger|mt|wp)\./i, '').gsub(/[A-Z]/, '_\0').downcase;

			content_type('text/xml', :charset => 'utf-8')

			send(method, command)

		end

		def get_users_blogs(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			blog = { :url => home_link(), :blogid => @setting.id, :blogName => @setting.blog_title }

			blogs = [blog]

			XMLRPC::Marshal.dump_response(blogs)

		end

		def get_categories(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			categories = tag_querying_service.find_all.map{ |t|
										{
											:categoryId => t.id,
											:title => t.title,
											:description => t.title,
											:htmlUrl => tag_link(t.slug),
											:rssUrl => ''
										}
									}

			XMLRPC::Marshal.dump_response(categories)

		end

		def get_recent_posts(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			limit = safe_number(command[1][3])

			limit = @setting.items_per_age if limit == 0

			posts = post_querying_service.find_all(0, limit).map { |p| map_post(p) }

			XMLRPC::Marshal.dump_response(posts)

		end

		def get_post(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			id = command[1][0];

			post = map_post(post_querying_service.get_by_id(id));

			XMLRPC::Marshal.dump_response(post)

		end

		def new_post(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			post_info = command[1][3]

			published_at = command[1][4] ? get_published_at(post_info) : nil;

			post = post_publishing_service.create(post_info['title'], post_info['wp_slug'], post_info['description'], published_at, post_info['mt_excerpt'], post_info['categories'])

			if defined?(CACHE)
				CACHE.delete('tags')
				CACHE.delete('home_page_posts')
			end

			XMLRPC::Marshal.dump_response(post.id)

		end

		def edit_post(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			updated = false;
			id = safe_number(command[1][0])

			unless id < 1
				post_info = command[1][3]
				published_at = command[1][4] ? get_published_at(post_info) : nil;

				post_publishing_service.update(id, post_info['title'], post_info['wp_slug'], post_info['description'], published_at, post_info['mt_excerpt'], post_info['categories'])
				updated = true
			end

			XMLRPC::Marshal.dump_response(updated)

		end

		def delete_post(command)

			return invalid_credential() unless valid_credential?(command[1][2], command[1][3])

			deleted = false;
			id = safe_number(command[1][1])

			unless id < 1
				post_publishing_service.destroy(id)
				deleted = true
			end

			XMLRPC::Marshal.dump_response(deleted)

		end

		def get_pages(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			limit = safe_number(command[1][3])

			limit = @setting.items_per_age if limit == 0

			pages = page_querying_service.find_all(0, limit).map { |p| map_page(p) }

			XMLRPC::Marshal.dump_response(pages)

		end

		def get_page(command)

			return invalid_credential() unless valid_credential?(command[1][2], command[1][3])

			id = command[1][1];

			page = map_page(page_querying_service.get_by_id(id));

			XMLRPC::Marshal.dump_response(page)

		end

		def new_page(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			page_info = command[1][3]

			published_at = command[1][4] ? get_published_at(page_info) : nil;

			page = page_publishing_service.create(page_info['title'], page_info['wp_slug'], page_info['description'], published_at)

			XMLRPC::Marshal.dump_response(page.id)

		end

		def edit_page(command)

			return invalid_credential() unless valid_credential?(command[1][2], command[1][3])

			updated = false;
			id = safe_number(command[1][1])

			unless id < 1
				page_info = command[1][4]
				published_at = command[1][5] ? get_published_at(page_info) : nil;

				page_publishing_service.update(id, page_info['title'], page_info['wp_slug'], page_info['description'], published_at)
				updated = true
			end

			XMLRPC::Marshal.dump_response(updated)

		end

		def delete_page(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			deleted = false;
			id = safe_number(command[1][3])

			unless id < 1
				page_publishing_service.destroy(id)
				deleted = true
			end

			XMLRPC::Marshal.dump_response(deleted)

		end

		def new_media_object(command)

			return invalid_credential() unless valid_credential?(command[1][1], command[1][2])

			media_object = command[1][3]
			name = File.basename(media_object['name'])
			data = media_object['bits']

			one_year = 60 * 60 * 24 * 365
			bucket_name = "media.#{@setting.aws_bucket}"

			AWS::S3::Base.establish_connection!(:access_key_id => @setting.aws_access_key_id, :secret_access_key => @setting.aws_secret_access_key)
			AWS::S3::S3Object.store(name, data, bucket_name, {:access => :public_read, :cache_control => "public, max-age=#{one_year.to_s}, must-revalidate", :expires => (Time.now + one_year).httpdate})

			result = {:file => name, :url => "http://#{bucket_name}.s3.amazonaws.com/#{name}" }

			XMLRPC::Marshal.dump_response(result)

		end

		private

		def map_post(post)
			{
				:postid => post.id,
				:userid => @setting.id,
				:dateCreated => post.published_at || post.created_at,
				:title => post.title,
				:description => post.content,
				:link => post_link(post.slug),
				:wp_slug => post.slug,
				:mt_excerpt => post.excerpt,
				:publish => !post.published_at.nil?,
				:categories => post.tags.map(&:title)
			}
		end

		def map_page(page)
			{
				:postid => page.id,
				:userid => @setting.id,
				:dateCreated => page.published_at || page.created_at,
				:title => page.title,
				:description => page.content,
				:link => page_link(page.slug),
				:wp_slug => page.slug,
				:publish => !page.published_at.nil?
			}
		end

		def get_published_at(content_info)

			published_at = content_info['dateCreated'].to_date() if !content_info['dateCreated'].nil?
			published_at = content_info['pubDate'].to_date() if published_at.nil? && !content_info['pubDate'].nil?
			published_at = Time.now.utc if published_at.nil?

			published_at;

		end

		def valid_credential?(user_name, password)

			@setting.login.eql?(user_name) && @setting.password.eql?(password.sha1)

		end

		def invalid_credential()

			@fault_code = 2041
			@fault_string = 'Invalid credential. Please specify correct UserName/Password and retry.'

			haml :fault

		end

	end
end
