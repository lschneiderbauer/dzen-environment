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
			@ap_list[object_path.to_sym] = Ap.new(dbus, object_path)
		end

		@properties = prop_if.GetAll("")[0]

		# watch for ap-list updates
		wlan_if.on_signal(dbus, "AccessPointAdded") do |object_path|
			@ap_list[object_path.to_sym] = Ap.new(dbus, object_path)
		end

		wlan_if.on_signal(dbus, "AccessPointRemoved") do |object_path|
			@ap_list.delete object_path.to_sym
		end

		wlan_if.on_signal(dbus, "PropertiesChanged") do |u|
			@properties.merge! u
		end
	end

end

class Networkmanager < Widget

	attr_reader :menu_width

	def initialize(dbus)

		@ap_man = ApManager.new dbus
		@menu_width = 0

	end

	def name
		"Wifi-Manager"
	end

	def to_s

		width = 0
		str = "^i(#{ICON_BASE}/wifi_02.xbm)\n"
		@ap_man.ap_list.each do |object_path, ap|
			
			# active ?
			if object_path = @ap_man.properties["ActiveAccessPoint"]
				color = "" ; color = "lightblue"
				str << "^i(#{ICON_BASE}/wifi_01.xbm) " 
			end

			# wpa ?
			if ap.properties["WpaFlags"] != ""
				str << "^i(#{ICON_BASE}/ac.xbm) "
			end

			# default-info
			str << "^fg(#{color})" <<
				ap.properties["HwAddress"] << " :: " <<
				ap.properties["Ssid"].to_s << "^fg() "

			# signal strength
			str << `echo #{ap.properties["Strength"]} | gdbar -fg 'lightblue' -bg '#494b4f' -h 7 -w 30`.chomp
			str << "   \n"
		
			# measure needed width
			tmp_width = (ap.properties["HwAddress"].size + ap.properties["Ssid"].to_s.size + 15) * 7.5
			width = tmp_width if tmp_width > width
		end
		
		@menu_width = width	
		return str
	end
	
end
