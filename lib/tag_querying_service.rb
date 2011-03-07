module ClassyBlog
	class TagQueryingService

		def get_by_title(title)

			Tag.first(:title => title)

		end

		def get_by_slug(slug)

			Tag.first(:slug => slug)

		end

		def find_published()

			Tag.all(:taggings => Tagging.all(:post => Post.all(:published_at.not => nil)), :order => [:title.asc])

		end

		def find_all()

			Tag.all(:order => [:title.asc])

		end

	end
end
