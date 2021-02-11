module Audiofeeler
  class Artist
    attr_accessor :name,
                  :reference,
                  :webpage

    attr_reader :albums

    def initialize
      @albums = []
    end

    def add_album(album)
      @albums << album
      album.artist = self
    end
  end
end
