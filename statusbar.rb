#!/usr/bin/ruby

require 'optparse'
require 'dbus'

require './dzen'
require './widgets/clock'
require './widgets/mpd'
require './widgets/cpu'
require './widgets/battery'
require './widgets/networkmanager'

ICON_BASE="/home/void/Pictures/icons"
BAR_HEIGHT=7
BAR_WIDTH=70


# manage script-options
#######################################
options = {}

# default options
options[:screen] = 1
options[:interval] = 2

OptionParser.new do |opts|
	opts.banner = "Usage: statusbar.rb [options]"

	opts.on("-s", "--screen [SCREENNUMBER]", "Set used Xinerama-screen") do |s|
		options[:screen] = s
	end

	opts.on("-i", "--interval [INTERVAL]", "Set interval for pushing data in seconds") do |i|
		options[:interval] = i
	end
end.parse!

# init dbus-connection
######################################
dbus = DBus::SystemBus.instance
dbus_main = DBus::Main.new
dbus_main << dbus

# init widgets
######################################
bat=Battery.new 3
clock=Clock.new 1
cpu=Cpu.new 3
mpd=Mpd.new 5
#wlan=Networkmanager.new dbus

# run dbus loop and restart everytime after kill
#Thread.new { dbus_main.run }

# get screen resolution(s)
# xrandr | grep '*'

# push to dzen
######################################
dzen_bar = Dzen.new "-xs #{options[:screen]}"
dzen_wlan = Dzen.new "-xs #{options[:screen]} -tw 20 -sa r -x 1380"	
loop do
	# write to bar
	dzen_bar.push(clock.to_s << " | " << mpd.to_s << " ^fg(grey)| ^r(600x2) |^fg() " <<
		cpu.to_s << " | " << bat.to_s << "\n")
	
	# write to wlan_app
	#dzen_wlan.push(wlan.to_s + "\n")

	# go to bed
	sleep options[:interval]

	trap "INT" do
		mpd.close
		dzen_bar.close
		dzen_wlan.close
		break
	end
end
