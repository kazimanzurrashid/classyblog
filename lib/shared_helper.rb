module ClassyBlog
	module SharedHelper

		def h(text)
      Rack::Utils.escape_html(text)
    end

		def throw_not_found()

			halt 404

		end

		def get_page_or_throw_not_found_when_invalid(page)

			number = safe_number(page)
			throw_not_found() unless number > 0

			number

		end

		def start_index(page)

			(page - 1) * @setting.items_per_page

		end

		def total_page(count)

			return 1 if count == 0 || @setting.items_per_page == 0

			return count / @setting.items_per_page if (count % @setting.items_per_page) == 0

			result = count.to_f() / @setting.items_per_page.to_f()

			result.floor + 1

		end

		def set_cache()

			expires @setting.cache_duration_in_seconds, :public, :must_revalidate if production? && !@setting.nil? && @setting.cache_duration_in_seconds > 0

		end

		def page_title()

			defined?(@title) && !@title.blank? ? "#{@title} - #{@setting.blog_title}" : @setting.blog_title

		end

		def field_validation(target, property)

			"<span class=\"field-validation-error\">#{target.errors[property][0]}</span>" unless target.errors[property].empty?

		end

		def safe_number(value)

			begin
				number = Integer(value)
			rescue
				number = 0
			end

			number

		end

	end
end
