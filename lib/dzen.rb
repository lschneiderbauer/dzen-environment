# takes care about dynamic dzen concerns
class Dzen

	BINARY="dzen2"

	attr_reader :width

	def initialize(add_paras)
		@add_paras = add_paras

		# get screen width
		@width = `xrandr | grep '*'`.split("x")[0].strip.to_i

		refresh(0,0)
	end

	def push(*widgets)
	
		# calculate string length
		length = 0
		spacer_count = 0
		widgets.each do |widget|
			if widget != :spacer
				length += widget.to_s.length
			else
				spacer_count += 1
			end
		end

		# build string
		str = "|"
		widgets.each do |widget|
			if widget != :spacer
				str << (" " + widget.to_s + " |")
			else
				str << " ^fg(grey)^r(#{(@width.to_f/1.5-length)/spacer_count}x2)^fg() |"
			end
		end
		str << "\n"
		
		# for dynamic line-number in menu-mode
		refresh(str.lines.count,
			str.lines.inject(0) do |width, line|
				line.size > width ? line.size : width
			end * 3
			)

		# write it to dzen
		@f.write str
		@f.flush
	end

	def close
		@f.close
	end


	private

	def refresh(l,width)
		if @f.nil? || l!=@l || (width!=@menu_width && l>1)
			@f.close unless @f.nil?

			#build exec string
			exec = "#{BINARY}"
				exec << " -l #{l-1}" if l>1
				exec << " -w #{width}" if l>1
				exec << " #{@add_paras}" if @add_paras != ""

			@f = IO.popen(exec,"w")
			@l = l
			@menu_width = width
		end
	end

end
