#!/usr/bin/ruby

ICON_BASE="/home/void/Pictures/icons"
BAR_HEIGHT=7
BAR_WIDTH=70

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
		`echo #{bat_perc} | gdbar -fg 'green' -bg '#494b4f' -h #{BAR_HEIGHT} -w #{BAR_WIDTH}`
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


class Mpd < Widget
# TODO
# remove mpc dependency and use mpd-lib instead
# make use of refresh_info

	def initialize(interval,interval_notav)
		@not_av_counter = 0 	# to make less queries if not available
		@interval_notav = interval_notav

		super(interval)
	end

	def name
		"MPD"
	end

	def to_s
		str = ""
		str = `mpc -h 192.168.0.1 current 2> /dev/null` if @not_av_counter == 0
		if str == ""
			@not_av_counter = @interval_notav if @not_av_counter == 0
			
			str = "info not available"
			@not_av_counter -= 1
		else
			@not_av_counter = 0
		end

		"^i(#{ICON_BASE}/note.xbm) " << str.chomp.ljust(50)
	end

	def refresh_info

	end
end



INTERVAL=2	# in seconds

bat=Battery.new(3)
clock=Clock.new(1)
cpu=Cpu.new(3)
mpd=Mpd.new(3,30)

loop do
	puts (clock.to_s << " | " << mpd.to_s << " ^fg(grey)| ^r(600x2) |^fg() " <<
		cpu.to_s << " | " << bat.to_s)
	STDOUT.flush
	sleep INTERVAL
end
