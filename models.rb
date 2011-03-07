require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'dm-aggregates'

configure :development, :production do
	DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/app.db")
end

module ClassyBlog

	module PublishableContent
		def published_at_in_short_format
			published_at.strftime("%Y-%m-%d")
		end

		def published_at_in_medium_format
			published_at.strftime("%d-%b-%Y")
		end

		def published_at_in_long_format
			published_at.strftime("%B %d, %Y")
		end
	end

	class Setting
		include DataMapper::Resource

		property :id, Serial
		property :blog_title, String, :length => 1..256, :required => true
		property :tag_line, String, :length => 256
		property :meta_keywords, String, :length => 512
		property :meta_description, String, :length => 512
		property :items_per_page, Integer, :required => true, :default => 10
		property :posts_in_home, Integer, :required => true, :default => 5
		property :cache_duration_in_seconds, Integer, :default => 0
		property :login, String, :length => 1..128, :required => true
		property :password, String, :length => 1..128, :required => true
		property :user_full_name, String, :length => 1..256, :required => true
		property :user_email, String, :length => 256, :format => :email_address
		property :user_bio, String, :length => 2048
		property :aws_access_key_id, String, :length => 256
		property :aws_secret_access_key, String, :length => 256
		property :aws_bucket, String, :length => 256
		property :aws_cdn_prefix, String, :length => 256
		property :google_analytics_code, String, :length => 24
		property :feed_burner_url, String, :length => 1024
		property :bing_app_id, String, :length => 64
		property :disqus_short_name, String, :length => 256
		property :typekit_code, String, :length => 24
		property :twitter_handle, String, :length => 256
	end

	class Page
		include DataMapper::Resource
		include PublishableContent

		property :id, Serial
		property :title, String, :length => 1..256, :required => true
		property :slug, Slug, :length => 1..256, :required => true, :unique => true
		property :content, Text, :required => true, :lazy => false
		property :created_at, DateTime, :required => true
		property :published_at, DateTime, :index => true

	end

	class Tag
		include DataMapper::Resource

		property :id, Serial
		property :title, String, :length => 1..256, :required => true, :index => true
		property :slug, Slug, :length => 1..256, :required => true, :unique => true
		property :posts_count, Integer, :required => true, :default => 0

		has n, :taggings
		has n, :posts, :through => :taggings

	end

	class Post
		include DataMapper::Resource
		include PublishableContent

		property :id, Serial
		property :title, String, :length => 1..256, :required => true
		property :slug, Slug, :length => 1..256, :required => true, :unique => true
		property :content, Text, :required => true, :lazy => false
		property :excerpt, String, :length => 512
		property :created_at, DateTime, :required => true
		property :published_at, DateTime, :index => true

		has n, :taggings
		has n, :tags, :through => :taggings, :order => [:title.asc]

		def summary
			excerpt.blank? ? content.match(/(.{240}.*?<\/p>)/m) : excerpt
		end

	end

	class Tagging
		include DataMapper::Resource

 	 property :post_id, Integer, :key => true
		property :tag_id, Integer, :key => true

		belongs_to :post, :key => true
		belongs_to :tag, :key => true
	end

	class Archive
		include DataMapper::Resource

		property :year, Integer, :key => true
		property :month, Integer, :key => true
		property :posts_count, Integer, :required => true, :default => 0

		def full_month_name
			Date::MONTHNAMES[month]
		end

		def short_month_name
			Date::ABBR_MONTHNAMES[month]
		end

	end

end

DataMapper.finalize

class Contact
	attr_accessor :name, :email, :subject, :message

	def initialize
		@errors = {}
		reset()
	end

	def errors
		@errors
	end

	def valid?

		reset()

		@errors[:name] = ['Name cannot be blank.'] if @name.blank?
		@errors[:email] = ['Email cannot be blank.'] if @email.blank?
		@errors[:subject] = ['Subject cannot be blank.'] if @subject.blank?
		@errors[:message] = ['Message cannot be blank.'] if @message.blank?

		@errors[:name].empty? && @errors[:email].empty? && @errors[:subject].empty? && @errors[:message].empty?

	end

	private

	def reset

		@errors.clear
		@errors[:name] = []
		@errors[:email] = []
		@errors[:subject] = []
		@errors[:message] = []

	end

end
