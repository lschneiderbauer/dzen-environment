#!/usr/bin/ruby

require 'optparse'
require 'dbus'

require './widgets/clock'
require './widgets/mpd'
require './widgets/cpu'
require './widgets/battery'
require './widgets/networkmanager'

ICON_BASE="/home/void/Pictures/icons"
BAR_HEIGHT=7
BAR_WIDTH=70
INTERVAL=2	# in seconds


# manage script-options
#######################################
options = {}

# default options
options[:screen] = 1

OptionParser.new do |opts|
	opts.banner = "Usage: statusbar.rb [options]"

	opts.on("-s", "--screen [SCREENNUMBER]", "Set used Xinerama-screen") do |s|
		options[:screen] = s
	end
end.parse!

# init dbus-connection
######################################
dbus = DBus::SystemBus.instance
dbus_main = DBus::Main.new
dbus_main << dbus

# init widgets
#######################################
bat=Battery.new 3
clock=Clock.new 1
cpu=Cpu.new 3
mpd=Mpd.new 5
wlan=Networkmanager.new dbus

# get screen resolution(s)
# xrandr | grep '*'

IO.popen("dzen2 -xs #{options[:screen]}","w+") do |bar|
IO.popen("dzen2 -xs #{options[:screen]} -tw 20 -sa r -x 1380 -w #{wlan.menu_width} -l 20","w+") do |wlan_app|

	loop do
		# write to bar
		bar.write(clock.to_s << " | " << mpd.to_s << " ^fg(grey)| ^r(600x2) |^fg() " <<
			cpu.to_s << " | " << bat.to_s)
		bar.flush

		# write to wlan_app
		p wlan.to_s
		wlan_app.write wlan.to_s
		wlan_app.flush
		
		# go to bed
		sleep INTERVAL

		trap "INT" do
			mpd.close
		end
	end

end
end
