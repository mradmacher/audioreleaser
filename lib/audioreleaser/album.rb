# frozen_string_literal: true

require 'shell_whisperer'

module Audioreleaser
  # Releases an album encoding audio files to a specific format, tagging them and packing to a nice zip file.
  class Album
    attr_accessor :title,
                  :artist,
                  :year,
                  :license,
                  :contact
    attr_reader :tracks

    def initialize(**args)
      @title = args[:title]
      @artist = args[:artist]
      @year = args[:year]
      @license = args[:license]
      @contact = args[:contact]
      @tracks = []
    end

    def add_track(track)
      track.album = self
      @tracks << track
    end
  end
end
