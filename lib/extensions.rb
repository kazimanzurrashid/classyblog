class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class String
  def sha1
		self.nil? || self.empty? ? self : Digest::SHA1.hexdigest(self)
  end
end

class Date
  def self.days_in_month(year, month)
		(Date.new(year, 12, 31) << (12 - month)).day
  end
end
