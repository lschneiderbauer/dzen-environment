require 'widgets/widget'
require 'librmpd'

class Mpd < Widget

	def initialize(interval)

		# open mpd connection and register callbacks
		super

		# first time fetch it manually
		@current_song = @mpd.current_song if @mpd.connected?
		@volume = @mpd.volume if @mpd.connected?
	end

	def name
		"MPD Client"
	end

	def to_s
		str = "^i(#{ICON_BASE}/note.xbm) "
		str << (@current_song.nil? ?  \
			"no played song" : \
			"[^fg(orange)#{@volume}^fg()] #{@current_song.artist} - #{@current_song.title}")
		str.ljust(90)
	end

	def close
		@mpd.disconnect
	end

	private

	def current_song_changed (song)
		@current_song = song
	end

	def volume_changed (volume)
		@volume = volume
	end
	
	def refresh_info
		if @mpd.nil? || !@mpd.connected?
			@mpd = MPD.new('192.168.0.1',6600)
			@mpd.register_callback(self.method('current_song_changed'), MPD::CURRENT_SONG_CALLBACK)
			@mpd.register_callback(self.method('volume_changed'), MPD::VOLUME_CALLBACK)
			@mpd.connect true
		end
	rescue
		
	end

end
