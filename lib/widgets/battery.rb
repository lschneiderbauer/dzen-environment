require 'widgets/widget'

class Battery < Widget
	
	def initialize(interval)
		@PREFIX = "/sys/class/power_supply/"
		
		super
	end

	def name
		"Battery"
	end

	def to_s
		bat_perc = @charge_now.to_f/@charge_full*100

		"^i(#{ICON_BASE}/bat_empty_01.xbm)^fg(" << ac_status_color << ")" << " (ac)^fg()" <<
		`echo #{bat_perc} | gdbar -fg 'green' -bg '#494b4f' -h #{BAR_HEIGHT} -w #{BAR_WIDTH}`.chomp
	end


	private

	def refresh_info	
		@bat_status = `cat #{@PREFIX}/CMB1/status`.chomp.downcase
		@charge_full = `cat #{@PREFIX}/CMB1/charge_full`.chomp.to_i
		@charge_now = `cat #{@PREFIX}/CMB1/charge_now`.chomp.to_i
		@ac_status = (`cat #{@PREFIX}/AC/online`.chomp.to_i == 1 ? 
			:connected : :disconnected)
	end

	def ac_status_color
		(@ac_status == :connected ? "green" : "orange")
	end
end
