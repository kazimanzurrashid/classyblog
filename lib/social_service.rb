require 'rexml/document'

module ClassyBlog
	class SocialService

		def feed_burner_reader_count(feed_url)

			date = Date.today - 2 #Feedburner is 2 day behind at this moment
			end_point = "http://feedburner.google.com/api/awareness/1.0/GetFeedData?uri=#{feed_url}&dates=#{date.strftime('%Y-%m-%d')}"

			begin

				xml = Net::HTTP.get_response(URI.parse(end_point)).body
				doc = REXML::Document.new(xml)

				return doc.get_elements('rsp/feed/entry')[0].attribute('circulation').value

			rescue

			end

			'N/A'

		end

		def twitter_follower_count(handle)

			end_point = "http://api.twitter.com/1/users/show/#{handle}.xml"

			begin

				xml = Net::HTTP.get_response(URI.parse(end_point)).body
				doc = REXML::Document.new(xml)

				return doc.get_text('user/followers_count').value

			rescue

			end

			'N/A'

		end

	end
end
