class Widget

	def initialize(interval)
		Thread.new { loop { refresh_info; sleep interval } }
	end

	def name
		return "default widget"
	end

	def to_s
		return ""
	end

end
