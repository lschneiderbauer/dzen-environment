require './widgets/widget'
require 'librmpd'

class Mpd < Widget

	def initialize(interval)

		# open mpd connection and register callbacks
		@mpd = MPD.new('192.168.0.1', 6600)
		
		@mpd.register_callback(self.method('current_song_changed'), MPD::CURRENT_SONG_CALLBACK)

		super

		# first time fetch it manually
		@current_song = @mpd.current_song if @mpd.connected?
	end

	def name
		"MPD Client"
	end

	def to_s
		str = "^i(#{ICON_BASE}/note.xbm) "
		str << (@current_song.nil? ?  \
			"no played song" : \
			@current_song.artist + " - " + @current_song.title)
		str.ljust(90)
	end

	def close
		@mpd.disconnect
	end

	private

	def current_song_changed (song)
		@current_song = song
	end
	
	def refresh_info
		@mpd.connect true unless @mpd.connected?
	rescue
		
	end

end
