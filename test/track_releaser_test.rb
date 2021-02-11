# frozen_string_literal: true

require 'test_helper'

describe Audiofeeler::TrackReleaser do
  before do
    @artist = Audiofeeler::Artist.new
    @artist.name = 'Jęczące Brzękodźwięki'

    @album = Audiofeeler::Album.new
    @album.title = 'Zagrajmy to razem'
    @artist.add_album(@album)

    @track = Audiofeeler::Track.new
    @track.title = 'Ta-bum-ta-bam'
    @track.file = File.open(File.join(FIXTURES_DIR, '1.wav'))
    @album.add_track(@track)
  end

  it 'creates ogg preview' do
    releaser = Audiofeeler::TrackReleaser.new(@track)
    releaser.with_release(Audiofeeler::Release::OGG) do |file_path|
      assert File.exist? file_path
      assert_equal 'Tabumtabam.ogg', File.basename(file_path)
      assert `file #{file_path}` =~ /Ogg/
    end
  end

  it 'creates mp3 preview' do
    releaser = Audiofeeler::TrackReleaser.new(@track)
    releaser.with_release(Audiofeeler::Release::MP3) do |file_path|
      assert File.exist? file_path
      assert_equal 'Tabumtabam.mp3', File.basename(file_path)
      assert `file #{file_path}` =~ /MPEG/
    end
  end
end
