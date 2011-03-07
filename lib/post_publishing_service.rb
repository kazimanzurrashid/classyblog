module ClassyBlog
	class PostPublishingService

		def create(title, slug, content, published_at, excerpt, tags)

			post = Post.new(:title => title, :slug => slug, :content => content, :published_at => published_at, :excerpt => excerpt, :created_at => Time.now.utc)

			post.slug = post.title.to_url if post.slug.blank?

			unless tags.empty?

				tags = unique_tags(tags)

				add_tags(post, tags)

			end

			if post.save() && !published_at.nil?
				increment_archive(published_at)
			end

			post

		end

		def update(id, title, slug, content, published_at, excerpt, tags)

			post = Post.get(id)

			old_published_at = post.published_at

			post.title = title
			post.slug = slug
			post.content = content
			post.published_at = published_at
			post.excerpt = excerpt
			post.slug = post.title.to_url if post.slug.blank?

			unless tags.empty?

				tags = unique_tags(tags)

				tags_to_remove = post.tags.select{|t| !tags.include?(t.title)}
				tags_to_add = tags.select{|t| !post.tags.any?{|tag| tag.title == t}}

				remove_tags(post, tags_to_remove)
				add_tags(post, tags_to_add)

			else

				remove_tags(post, post.tags)

			end

			if post.save()

				unless published_at.eql?(old_published_at)

					unless old_published_at.nil?
						decrement_archive(old_published_at)
					end

					unless published_at.nil?
						increment_archive(published_at)
					end

				end

			end

			post

		end

		def destroy(id)

			post = Post.get(id)
			published_at = post.published_at

			unless post.tags.empty?
				remove_tags(post, post.tags)
			end

			if post.destroy() && !published_at.nil?
				decrement_archive(published_at)
			end

		end

		private

		def unique_tags(tags)

			tags = tags.split(',') if tags.is_a?(String)

			tags.map{|t| t.strip }.select{|t| !t.empty? }.uniq

		end

		def add_tags(post, tags)
		
			tags.each do |t|

				tag = Tag.first_or_create({:title => t}, {:slug => t.to_url})
				tag.posts_count += 1
				post.tags << tag

			end

		end

		def remove_tags(post, tags)

			tags.each do |tag|

				tag.posts_count -= 1;
				tag.save()

			end

			tags.map{|t| t.id}.each do |id|

				link = Tagging.first(:post_id => post.id, :tag_id => id)
				link.destroy()

				post.tags.delete_if{|t| t.id == id}

			end

		end

		def increment_archive(published_at)

			archive = Archive.first_or_create(:year => published_at.year, :month => published_at.month)
			archive.posts_count += 1
			archive.save()

		end

		def decrement_archive(published_at)

			archive = Archive.first_or_create(:year => published_at.year, :month => published_at.month)
			archive.posts_count -= 1
			archive.save()

		end

	end
end
