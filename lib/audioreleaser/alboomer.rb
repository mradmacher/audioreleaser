# frozen_string_literal: true

require 'yaml'

module Audioreleaser
  class Alboomer
    def self.load_album(yaml)
      a = YAML.load(yaml)
      Album.new(
        title: a['title'],
        artist: a['artist'],
        year: a['year'],
      ).tap do |album|
        a['tracks'].each do |t|
          album.add_track(
            title: t['title'],
            artist: t['artist'],
            comment: t['comment'],
          )
        end
      end
    end
  end
end
