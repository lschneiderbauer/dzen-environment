require 'widgets/widget'

class Clock < Widget

	def name
		"Clock"
	end

	def to_s
		"^fg(darkgrey)#{@time.day.to_s.rjust(2,"0")}.#{@time.mon.to_s.rjust(2,"0")}^fg()" <<
		" ^fg(lightblue)#{@time.hour.to_s.rjust(2,"0")}:#{@time.min.to_s.rjust(2,"0")}^fg()"
	end


	private

	def refresh_info
		@time = Time.now
	end

end
