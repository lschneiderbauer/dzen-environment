# takes care about dynamic dzen concerns
class Dzen

	BINARY="dzen2"

	def initialize(add_paras)
		@add_paras = add_paras
		refresh(0,0)
	end

	def push(str)
		refresh(str.lines.count,
			str.lines.inject(0) do |width, line|
				line.size > width ? line.size : width
			end * 3
			)
		@f.write(str)
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

			p exec
			p @menu_width
			p @l
		end
	end

end
