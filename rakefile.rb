require 'dependencies.rb'
require 'dm-migrations'

task :ensure_schema do
	DataMapper.auto_upgrade!
end

task :load_setting do
	ClassyBlog::Setting.destroy

	setting = ClassyBlog::Setting.new

	setting.blog_title = 'Kazi Manzur Rashid'
	setting.tag_line = 'Sharing Thoughts and Learning'
	setting.meta_keywords = '.NET, ASP.NET, C#, Linq, Microformat, Html5, Css3, jQuery, Ruby, REST, Agile, ORM, TDD, BDD, DDD, Usability, Developer, Bangladesh'
	setting.meta_description = 'Personal blog of Kazi Manzur Rashid'

	setting.login = 'kazimanzurrashid'
	setting.password = '1Eatmy~pie'.sha1
	setting.user_full_name = 'Kazi Manzur Rashid'
	setting.user_email = 'kazimanzurrashid@gmail.com'
	setting.user_bio = '<img class="photo" src="http://assets.kazimanzurrashid.s3.amazonaws.com/1.0.1/images/me.jpg" alt="Kazi Manzur Rashid Photo"/>Hi, I am <a class="fn email" href="mailto:kazimanzurrashid@gmail.com">Kazi Manzur Rashid</a>, a <span class="title">Software developer</span> living in <span class="adr"><span class="locality">Dhaka</span>, <span class="country-name">Bangladesh</span></span> and working as an independent consultant. This is my personal <a class="url" href="http://kazimanzurrashid.com">web log</a> where I occasionally write about developing world class web applications targeting Microsoft .NET Platform. Beside Microsoft .NET, I do have sheer interest in Ruby, Rails and micro framework like Sinatra. I am also an early adopter, open standard admirer as well as open source enthusiast. I love \'80&rsquo;s music and believe only superman can break Sachin Tendulkar&rsquo;s world records.'

	setting.aws_access_key_id = 'PUT YOUR ACCESS KEY'
	setting.aws_secret_access_key = 'PUT YOUR SECRET KEY'
	setting.aws_bucket = 'PUT YOUR BUCKET NAME'
	#setting.aws_cdn_prefix = 'cdn'

	setting.google_analytics_code = 'PUT YOUR ANALYTIC CODE'
	setting.feed_burner_url = 'PUT YOUR FEEDBURNER URL'

	setting.bing_app_id = 'PUT YOUR BING APP ID'
	setting.disqus_short_name = 'PUT YOUR SHORT NAME'
	setting.typekit_code = 'PUT YOUR CODE'

	setting.twitter_handle = 'PUT YOUR HANDLE'

	setting.save()	
end

task :load_tags do

	ClassyBlog::Tag.destroy

	insert_tag = Proc.new {|name| ClassyBlog::Tag.new(:title => name, :slug => name.to_url).save() }

	insert_tag.call("General")
	insert_tag.call(".NET")
	insert_tag.call("ASP.NET MVC")
	insert_tag.call("ORM")
	insert_tag.call("Ruby")
	insert_tag.call("Sinatra")
	insert_tag.call("Html5")
	insert_tag.call("Css3")
	insert_tag.call("jQuery")
	insert_tag.call("Dependency Injection")
	insert_tag.call("Unit Test")
	insert_tag.call("Foundation")
	insert_tag.call("Pet Projects")	

end

task :purge_all do
	ClassyBlog::Tag.destroy
	ClassyBlog::Page.destroy
	ClassyBlog::Post.destroy
	ClassyBlog::Setting.destroy
end
