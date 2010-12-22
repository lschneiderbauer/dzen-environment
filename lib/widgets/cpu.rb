require 'widgets/widget'

class Cpu < Widget
# TODO
# don't use gcpubar (ugly style)
# make use of refresh_info

	def name
		"Cpu-Usage"
	end

	def to_s

		str = ""
               	str << "^i(#{ICON_BASE}/fs_01.xbm)"
	        str << `echo #{@cpu_usage} | gdbar -fg 'lightblue' -bg '#494b4f' -h #{BAR_HEIGHT} -w #{BAR_WIDTH}`.chomp

	end


	private

	def refresh_info

		usage = 0
		`ps -Ao pcpu`.lines do |line|
			usage += line.to_f
		end

		@cpu_usage = usage
	end

end
