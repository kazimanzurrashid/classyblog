module ClassyBlog
	class PostQueryingService

		def get_by_id(id)

			Post.get(id)

		end

		def get_published_by_slug(slug)

			Post.first(:slug => slug, :published_at.not => nil)

		end

		def find_all(offset, items_per_page)

			Post.all(:order => [:created_at.desc], :offset => offset, :limit => items_per_page)

		end

		def find_published(offset, items_per_page)

			Post.all(:published_at.not => nil, :order => [:published_at.desc], :offset => offset, :limit => items_per_page)

		end

		def count_published()

			Post.count(:published_at.not => nil)

		end

		def find_recent(items_per_page)

			find_published(0, items_per_page)

		end

		def find_published_by_date_range(start_date, end_date)

			Post.all(:published_at.gte => start_date, :published_at.lte => end_date, :order => [:published_at.desc])

		end

		def count_published_by_date_range(start_date, end_date)

			Post.count(:published_at.gte => start_date, :published_at.lte => end_date)

		end

		def find_published_by_year(year, offset, items_per_page)

			start_date = Date.new(year, 1, 1)
			end_date = Date.new(year, 12, 31)

			find_published_by_date_range(start_date, end_date).all(:offset => offset, :limit => items_per_page)

		end

		def count_published_by_year(year)

			start_date = Date.new(year, 1, 1)
			end_date = Date.new(year, 12, 31)

			count_published_by_date_range(start_date, end_date)

		end

		def find_published_by_year_and_month(year, month, offset, items_per_page)

			start_date = Date.new(year, month, 1)
			end_date = Date.new(year, month, Date.days_in_month(year, month))

			find_published_by_date_range(start_date, end_date).all(:offset => offset, :limit => items_per_page)

		end

		def count_published_by_year_and_month(year, month)

			start_date = Date.new(year, month, 1)
			end_date = Date.new(year, month, Date.days_in_month(year, month))

			count_published_by_date_range(start_date, end_date)

		end

		def find_published_by_year_month_and_day(year, month, day, offset, items_per_page)

			start_date = DateTime.new(year, month, day, 0, 0, 0)
			end_date = DateTime.new(year, month, day, 23, 59, 59)

			find_published_by_date_range(start_date, end_date).all(:offset => offset, :limit => items_per_page)

		end

		def count_published_by_year_month_and_day(year, month, day)

			start_date = DateTime.new(year, month, day, 0, 0, 0)
			end_date = DateTime.new(year, month, day, 23, 59, 59)

			count_published_by_date_range(start_date, end_date)

		end

		def find_published_by_tag(id, offset, items_per_page)

			Post.all(:published_at.not => nil, :taggings => Tagging.all(:tag => Tag.all(:id => id)), :order => [:published_at.desc], :offset => offset, :limit => items_per_page)

		end

		def count_published_by_tag(id)

			Post.count(:published_at.not => nil, :taggings => Tagging.all(:tag => Tag.all(:id => id)))

		end

		def find_archives()

			Archive.all(:posts_count.gt => 0, :order => [:year.desc, :month.desc])

		end

	end
end
