require 'widgets/widget'

class Cpu < Widget
# TODO
# don't use gcpubar (ugly style)
# make use of refresh_info

	def name
		"Cpu-Usage"
	end

	def to_s

		str = `gcpubar -c 2 -i 0.1 -fg 'blue' -bg '#494b4f' -h #{BAR_HEIGHT} -w #{BAR_WIDTH}`
		str = str.split("\n")[1].chomp
		str.slice!(0..4)
		"^i(#{ICON_BASE}/fs_01.xbm) " << str
	end

	private

	def refresh_info
		
	end

end
