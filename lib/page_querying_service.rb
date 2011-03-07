module ClassyBlog
	class PageQueryingService

		def get_by_id(id)

			Page.get(id)

		end

		def get_published_by_slug(slug)

			Page.first(:slug => slug, :published_at.not => nil)

		end

		def find_all(offset, items_per_page)

			Page.all(:order => [:created_at.desc], :offset => offset, :limit => items_per_page)

		end

		def find_published()

			Page.all(:published_at.not => nil, :order => [:published_at.desc])

		end

		def count_published()

			Page.count(:published_at.not => nil)

		end

	end
end
