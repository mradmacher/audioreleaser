# frozen_string_literal: true

module Audioreleaser
  # Collection of tags for an audio file.
  class Tag
    attr_accessor :album,
                  :artist,
                  :album_artist,
                  :title,
                  :rank,
                  :year,
                  :comment

    def initialize(**args)
      @album = args[:album]
      @artist = args[:artist]
      @album_artist = args[:album_artist]
      @year = args[:year]
      @license = args[:license]
      @contact = args[:contact]
      @title = args[:title]
      @rank = args[:rank]
      @comment = args[:comment]
    end

    def self.build_extended_comment(comment, license: nil, contact: nil)
      components = []
      components << comment if comment
      components << '---' if !components.empty? && (license || contact)
      components << license.to_s if license
      components << contact.to_s if contact
      components.join("\n")
    end
  end
end
