require './widgets/widget'

NM_DBUS_SERVICE="org.freedesktop.NetworkManager"

class Ap
	include Comparable

	attr_reader :properties

	def initialize(dbus, object_path)
		ap_obj = dbus.service(NM_DBUS_SERVICE) \
			.object object_path
		ap_obj.introspect

		ap_if = ap_obj["org.freedesktop.NetworkManager.AccessPoint"]
		prop_if = ap_obj["org.freedesktop.DBus.Properties"]
		
		@properties = prop_if.GetAll("")[0]
		
		# watch for updates
		ap_if.on_signal(dbus, "PropertiesChanged") do |u|
			@properties.merge! u
		end
	end

	def <=>(another)
		self.properties <=> self.properties
	end

end

class ApManager
	attr_reader :ap_list, :properties
	
	def initialize(dbus)
		@ap_list = {}

		# initialize AP-list
		wlan_obj = dbus.service(NM_DBUS_SERVICE) \
			.object "/org/freedesktop/NetworkManager/Devices/1"
		wlan_obj.introspect
		wlan_if = wlan_obj["org.freedesktop.NetworkManager.Device.Wireless"]
		prop_if = wlan_obj["org.freedesktop.DBus.Properties"]

		wlan_if.GetAccessPoints[0].each do |object_path|
			@ap_list[object_path] = Ap.new(dbus, object_path)
		end

		@properties = prop_if.GetAll("")[0]

		# watch for ap-list updates
		wlan_if.on_signal(dbus, "AccessPointAdded") do |object_path|
			@ap_list[object_path] = Ap.new(dbus, object_path)
		end

		wlan_if.on_signal(dbus, "AccessPointRemoved") do |object_path|
			@ap_list.delete object_path
		end

		wlan_if.on_signal(dbus, "PropertiesChanged") do |u|
			@properties.merge! u
		end
	end
end

class Networkmanager < Widget

	def initialize(dbus)
		@ap_man = ApManager.new dbus
	end

	def name
		"Wifi-Manager"
	end

	def to_s

		str = "^i(#{ICON_BASE}/wifi_02.xbm)\n"
		@ap_man.ap_list.each do |object_path, ap|
			
			# active ?
			color = ""
			if object_path == @ap_man.properties["ActiveAccessPoint"]
				color = "lightblue"
				str << "^i(#{ICON_BASE}/wifi_01.xbm) " 
			end

			# wpa ?
			if ap.properties["WpaFlags"] != ""
				str << "^i(#{ICON_BASE}/ac.xbm) "
			end

			# default-info
			ssid = ap.properties["Ssid"].inject("") {|mem,elem| mem << elem.chr}
			str << "^fg(#{color})" <<
				ssid << " :: " <<
				ap.properties["HwAddress"] << "^fg() "

			# signal strength
			str << `echo #{ap.properties["Strength"]} | gdbar -fg 'white' -bg '#494b4f' -h 7 -w 30`.chomp
			str << "   \n"
		end
		
		return str
	end
	
end
