module Audiofeeler
  class Album
    attr_accessor :title,
                  :reference,
                  :year,
                  :license,
                  :artist

    attr_reader :tracks,
                :attachments,
                :releases

    def initialize
      @tracks = []
      @attachments = []
      @releases = []
    end

    def add_track(track)
      @tracks << track
      track.album = self
    end

    def add_release(release)
      @releases << release
      release.album = self
    end

    def add_attachment(attachment)
      @attachments << attachment
      attachment.album = self
    end
  end
end
