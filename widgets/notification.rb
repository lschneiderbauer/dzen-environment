require './widgets/widget'

class Notification < Widget

	def initialize(dbus)

		# set up dbus service
		#service = dbus.request_service("org.freedesktop.StatusNotifierHost-dzenenv")

		# set up dbus interface
		knotify_obj = dbus.service("org.kde.knotify") \
			.object "/Notify"
		knotify_obj.introspect

		knotify_if = knotify_obj["org.kde.KNotify"]

		knotify_if.on_signal(dbus,"notificationActivated") do |o|
			p "notification activated"
		end

		knotify_if.on_signal(dbus,"notificationClosed") do |o|
			p "notification closed"
		end

		knotify_if.event("event","fromapp",[],"title","text",[],[],400,0)

		# try registering (?)
		#p service.name
		#kded_if.RegisterStatusNotifierHost service.name

=begin
		# get some props
		items = prop_if.Get("","RegisteredStatusNotifierItems")[0]
		p items

		items.each do |object_path|

			item_obj = dbus.service(object_path.split("/")[0]) \
				.object "/StatusNotifierItem"
			item_obj.introspect
			p "im here"

			item_if = item_obj["org.kde.StatusNotifierItem"]
			item_prop_if = item_obj["org.freedesktop.DBus.Properties"]
			p item_prop_if.GetAll("")[0]

			item_if.on_signal(dbus, "NewStatus") do |o|
				p "new status from #{object_path}"
			end

		end

		p prop_if.Get("","IsStatusNotifierHostRegistered")[0]
		# why false? should be true



		kded_if.on_signal(dbus, "StatusNotifierItemRegistered") do |o|
			p "statusnotifieritem registered"
		end

		kded_if.on_signal(dbus, "StatusNotifierItemUnregistered") do |o|
			p "statusnotifieritem unregistered"
		end

		kded_if.on_signal(dbus, "StatusNotifierHostRegistered") do |o|
			p "statusnotifier host registered"
		end
=end

	end

end
