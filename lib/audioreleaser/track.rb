# frozen_string_literal: true

module Audioreleaser
  class Track
    attr_accessor :file, :title, :rank, :comment, :artist, :album

    def initialize(file, **args)
      @file = file
      @title = args[:title]
      @rank = args[:rank]
      @comment = args[:comment]
      @artist = args[:artist]
      @album = args[:album]
    end
  end
end
