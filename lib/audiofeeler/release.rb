module Audiofeeler
  class Release
    OGG = 'ogg'
    FLAC = 'flac'
    MP3 = 'mp3'
    ZIP = 'zip'
    URL = 'url'
    FORMATS = [MP3, OGG, FLAC, ZIP, URL].freeze

    attr_accessor :format, :album
  end
end
