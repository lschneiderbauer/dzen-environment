#!/usr/bin/ruby

ICON_BASE="/home/void/Pictures/icons"
INTERVAL=2	# in seconds

class Ap
	include Comparable

	attr_accessor :active, :hwaddr, :ssid, :wpa, :strength

	def initialize(active, hwaddr, ssid)
		@active = active
		@hwaddr = hwaddr
		@ssid = ssid

		# get additional info
		@strength=`cnetworkmanager --ap-info=#{@hwaddr} | grep Strength`.split('|')[1].strip
		@wpa=(`cnetworkmanager --ap-info=#{@hwaddr} | grep WpaFlags`.split('|')[1].strip!="")

	end

	def self.parse(str)
		ar = str.split('|').each {|split| split.strip!}

		self.new(ar[0], ar[1], ar[2])
	end

	def <=>(another)
		self.active <=> another.active &&
		self.hwaddr <=> another.hwaddr &&
		self.ssid <=> another.ssid &&
		self.strength <=> another.strength &&
		self.wpa <=> another.wpa
	end

end

class ApManager
	attr_accessor :to_repaint, :ap_list
	
	def initialize
		@ap_list = []
		refresh
		@to_repaint = true
	end

	def refresh
		@to_repaint = false

		tmp_ap_list = []
		cnet_out = `cnetworkmanager -a`
		cnet_out.each_line do |line|
			(tmp_ap_list<< Ap.parse(line)) if (line[0,1]=='*' || line[0,1]==' ')
		end

		@to_repaint = true if @ap_list != tmp_ap_list
		@ap_list = tmp_ap_list
	end

end


man = ApManager.new
pid = 0

loop do

	if man.to_repaint

		width = 0
		str = "^i(#{ICON_BASE}/wifi_02.xbm)\n"
		man.ap_list.each do |ap|
			
			# active ?
			if ap.active
				color = "" ; color = "lightblue"
				str << "^i(#{ICON_BASE}/wifi_01.xbm) " 
			end

			# wpa ?
			if ap.wpa
				str << "^i(#{ICON_BASE}/ac.xbm) "
			end

			# default-info
			str << "^fg(#{color})" <<
				ap.hwaddr << " :: " <<
				ap.ssid << "^fg() "

			# signal strength
			str << `echo #{ap.strength} | gdbar -fg 'lightblue' -bg '#494b4f' -h 7 -w 30`.chomp
			str << "   \n"
		
			tmp_width = (ap.hwaddr.size + ap.ssid.size + 15) * 7.5
			width = tmp_width if tmp_width > width
		end
		str.chomp!

		# restart process
		Process.kill("SIGTERM",pid) if pid != 0
		pid = fork {`echo "#{str}" | dzen2 -tw 20 -x 1380 -sa r -w #{width} -l #{man.ap_list.size+1} -p`}
	
	end
	man.refresh

	sleep INTERVAL	
end
