class Kopete < Widget

	def initialize(interval,dbus)

		@dbus = dbus
		@messages = {}

		# init dbus
		refresh_data

		super(interval)
	
	end

	def name
		"Kopete Status Notifier"
	end

	def offline?
		@kopete_obj.nil?
	end

	def to_s

		str = ""
		
		if offline?
			str << "^fg(lightred)"
		else
			if @messages.empty?
				str << "^fg()"
			else
				str << "^fg(green)"
			end
		end

		str << "^i(#{ICON_BASE}/mail.xbm)^fg()"

	end


	private


	# because kopete could run, could not run and be started during statusbar-run-phase
	def refresh_data

		if offline?

			begin
				@kopete_obj = @dbus.service("org.kde.kopete") \
					.object("/Kopete")
				@kopete_obj.introspect

				kopete_if = @kopete_obj["org.kde.Kopete"]


				# update it manually the first time
				kopete_if.contacts[0].each do |id|
					update_messages kopete_if.contactProperties(id)[0]
				end
				
				# wait for signals
				kopete_if.on_signal(@dbus, "contactChanged") do |id|	
					update_messages kopete_if.contactProperties(id)[0]
				end

			rescue DBus::Error
				@kopete_obj = nil
			end

		end
	end

	def update_messages (props)

		msg = props["pending_messages"][0]
		if msg.nil?
			@messages.delete props["id"]
		else
			@messages[props["id"]] = props["display_name"]
		end

	end
	
end
