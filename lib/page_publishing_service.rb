module ClassyBlog
	class PagePublishingService

		def create(title, slug, content, published_at)

			page = Page.new(:title => title, :slug => slug, :content => content, :published_at => published_at, :created_at => Time.now.utc)

			page.slug = page.title.to_url if page.slug.blank?

			page.save()

			page

		end

		def update(id, title, slug, content, published_at)

			page = Page.get(id)

			page.title = title
			page.slug = slug
			page.content = content
			page.published_at = published_at
			page.slug = page.title.to_url if page.slug.blank?

			page.save()

			page

		end

		def destroy(id)

			page = Page.get(id)
			page.destroy()

		end

	end
end
