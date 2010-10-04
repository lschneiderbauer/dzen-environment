require './widgets/widget'
require 'librmpd'

class Mpd < Widget

	def initialize

		# open mpd connection and register callbacks
		@mpd = MPD.new('192.168.0.1', 6600)
		
		@mpd.register_callback(self.method('current_song_changed'), MPD::CURRENT_SONG_CALLBACK)
		@mpd.connect true

		@current_song = @mpd.current_song
	end

	def name
		"MPD Client"
	end

	def to_s
		str = "^i(#{ICON_BASE}/note.xbm) " \
			<< (@current_song.nil? ?  "no played song" : @current_song.artist + " - " + @current_song.title) .ljust(50)
	end

	def close
		@mpd.disconnect
	end

	private

	def current_song_changed (song)
		@current_song = song
	end

end
