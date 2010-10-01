#!/usr/bin/ruby

ICON_BASE="/home/void/Pictures/icons"
BAR_HEIGHT=7
BAR_WIDTH=70

class Widget

	def name
		return "default widget"
	end

	def to_s
		return ""
	end

end

class Battery < Widget
	
	def initialize
		@PREFIX = "/sys/class/power_supply/"
		@BAT_SIZE = 20
		@BAT_FULL_CHAR = "#"
		@BAT_LOW_CHAR= "-"
		
		refresh_info
	end

	def name
		"Battery"
	end

	def to_s
		refresh_info

		bat_perc = @charge_now.to_f/@charge_full*100
		bat_full_num = (@BAT_SIZE * bat_perc / 100).to_i

		"^i(#{ICON_BASE}/bat_empty_01.xbm)^fg(" << ac_status_color << ")" << " (ac)^fg()" <<
		#"^fg(blue)%[^fg(green)" << @BAT_FULL_CHAR * bat_full_num << "^fg()" <<
		#"^fg(red)" << @BAT_LOW_CHAR * (@BAT_SIZE-bat_full_num) << "^fg(blue)]^fg()" <<
		#"^fg(blue)" << bat_perc.to_s.rjust(4) << "^fg()"
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
		`date +'^fg(darkgrey)%a %d.%m ^fg(lightblue)%H:%M^fg()'`.chomp
	end

end


class Cpu < Widget

	def name
		"Cpu-Usage"
	end

	def to_s
		str = `gcpubar -c 2 -i 0.1 -fg 'blue' -bg '#494b4f' -h #{BAR_HEIGHT} -w #{BAR_WIDTH}`
		str = str.split("\n")[1].chomp
		str.slice!(0..4)
		"^i(#{ICON_BASE}/fs_01.xbm) " << str
	end

end


class Mpd < Widget

	def initialize
		@not_av_counter = 0 	# to make less queries if not available
	end

	def name
		"MPD"
	end

	def to_s
		str = ""
		str = `mpc -h 192.168.0.1 current 2> /dev/null` if @not_av_counter == 0
		if str == ""
			@not_av_counter = 30 if @not_av_counter == 0
			
			str = "info not available"
			@not_av_counter -= 1
		else
			@not_av_counter = 0
		end

		"^i(#{ICON_BASE}/note.xbm) " << str.ljust(50)
	end
end



INTERVAL=2	# in seconds

bat=Battery.new
clock=Clock.new
cpu=Cpu.new
mpd=Mpd.new

loop do
	puts (clock.to_s << " | " << mpd.to_s << " ^fg(grey)| ^r(600x2) |^fg() " <<
		cpu.to_s << " | " << bat.to_s)
	STDOUT.flush
	sleep INTERVAL	
end
