# frozen_string_literal: true

require 'yaml'

module Audioreleaser
  class Alboomer
    def self.load_album(yaml, filepaths = [])
      a = YAML.load(yaml)
      Album.new(
        title: a['title'],
        artist: a['artist'],
        year: a['year'],
      ).tap do |album|
        a['tracks'].each_with_index do |t, i|
          album.add_track(
            file: filepaths[i],
            title: t['title'],
            artist: t['artist'],
            comment: t['comment'],
          )
        end
      end
    end
  end
end
