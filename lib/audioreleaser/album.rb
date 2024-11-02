# frozen_string_literal: true

require 'shell_whisperer'

module Audioreleaser
  # Describes album properties.
  Album = Struct.new(:title, :artist, :year) do
    def tracks
      @tracks ||= []
    end

    def add_track(track)
      track.album = self
      tracks << track
    end
  end
end
