require 'rexml/document'

module ClassyBlog
	class BlogML

		def post_publishing_service

			@@post_publishing_service ||= PostPublishingService.new

		end

		def page_publishing_service

			@@page_publishing_service ||= PagePublishingService.new

		end

		def import(xml, count = 0)

			doc = REXML::Document.new(xml)

			blog_categories = {}

			doc.elements.each('blog/categories/category') do |category_element|
				blog_categories[category_element.attribute('id').value] = category_element.get_text('title').value
			end

			blog_posts = []

			doc.elements.each('blog/posts/post') do |post_element|

				title = post_element.get_text('title').value
				slug = post_element.get_text('post-name').value
				content = post_element.get_text('content').value
				published_at = DateTime.parse(post_element.attribute('date-modified').value)

				categories = []

				post_element.elements.each('categories/category') do |category_element|

					category_id = category_element.attribute('ref').value
					category_name = blog_categories[category_id]

					categories << category_name

				end

				blog_posts << {:title => title, :slug => slug, :published_at => published_at, :content => content, :categories => categories }

			end

			counter = 0

			blog_posts.reverse.each do |post|

				post_publishing_service.create(post[:title], post[:slug], post[:content], post[:published_at], nil, post[:categories])
				counter += 1

				if (count > 0) && (counter == count)
					break
				end

			end

		end

		def export()
		end

	end
end
