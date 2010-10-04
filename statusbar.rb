#!/usr/bin/ruby

require './widgets/clock'
require './widgets/mpd'
require './widgets/cpu'
require './widgets/battery'

ICON_BASE="/home/void/Pictures/icons"
BAR_HEIGHT=7
BAR_WIDTH=70
INTERVAL=2	# in seconds


# initialize widgets
bat=Battery.new(3)
clock=Clock.new(1)
cpu=Cpu.new(3)
mpd=Mpd.new

# get screen resolution(s)
# xrandr | grep '*'

IO.popen("dzen2","w+") do |f|

	loop do

		f.write(clock.to_s << " | " << mpd.to_s << " ^fg(grey)| ^r(600x2) |^fg() " <<
			cpu.to_s << " | " << bat.to_s)
		f.flush
		sleep INTERVAL

		trap "INT" do
			mpd.close
		end
	end

end
