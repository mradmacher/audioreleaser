# frozen_string_literal: true

require 'shell_whisperer'

module Audioreleaser
  # Describes album properties.
  Album = Struct.new(:title, :artist, :year) do
    def tracks
      @tracks ||= []
    end

    def add_track(file: nil, title: nil, comment: nil, artist: nil)
      tracks << Track.new(album: self, rank: tracks.size + 1, file:, title:, comment:, artist:)
    end
  end
end
