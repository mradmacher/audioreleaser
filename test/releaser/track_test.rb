# frozen_string_literal: true

require 'test_helper'

describe Audiofeeler::Releaser::Track do
  before do
    @album = Audiofeeler::Releaser::Album.new
    @track = Audiofeeler::Releaser::Track.new(
      File.new(File.join(FIXTURES_DIR, '1.wav')),
      title: 'Ta-bum-ta-bam'
    )
  end

  describe 'file name without rank tag' do
    before do
      @track.rank = nil
    end

    it 'creates ogg release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        assert File.exist? file_path
        assert_equal 'Tabumtabam.ogg', File.basename(file_path)
        assert `file #{file_path}` =~ /Ogg/
      end
    end

    it 'creates mp3 release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        assert File.exist? file_path
        assert_equal 'Tabumtabam.mp3', File.basename(file_path)
        assert `file #{file_path}` =~ /MPEG/
      end
    end

    it 'creates flac release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        assert File.exist? file_path
        assert_equal 'Tabumtabam.flac', File.basename(file_path)
        assert `file #{file_path}` =~ /FLAC/
      end
    end
  end

  describe 'file name with rank tag' do
    before do
      @track.rank = 2
    end

    it 'creates ogg release with title prefixed by rank' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        assert File.exist? file_path
        assert_equal '02-Tabumtabam.ogg', File.basename(file_path)
        assert `file #{file_path}` =~ /Ogg/
      end
    end

    it 'creates mp3 release with title prefixed by rank' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        assert File.exist? file_path
        assert_equal '02-Tabumtabam.mp3', File.basename(file_path)
        assert `file #{file_path}` =~ /MPEG/
      end
    end

    it 'creates flac release with title prefixed by rank' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        assert File.exist? file_path
        assert_equal '02-Tabumtabam.flac', File.basename(file_path)
        assert `file #{file_path}` =~ /FLAC/
      end
    end
  end

  describe 'with album' do
    before do
      @album.add_track(@track)
    end

    it 'defaults artist to album artist if artist not specified in track' do
      @track.artist = nil
      @album.artist = 'Jęczące Brzękodźwięki'
      tagger = Audiofeeler::Releaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end
    end

    it 'uses artist name from track if set' do
      @track.artist = 'Świszczące Fujary'
      @album.artist = 'Jęczące Brzękodźwięki'
      tagger = Audiofeeler::Releaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end
    end

    it 'sets all tags from album and track' do
      @album.artist = 'Album Artist'
      @album.year = 2021
      @album.title = 'Album Title'
      @album.license = Audiofeeler::Releaser::License::CC_BY_40
      @album.contact = 'http://example.com'
      @track.artist = 'Track Artist'
      @track.title = 'Track Title'
      @track.rank = 3
      @track.comment = 'Comment'
      tagger = Audiofeeler::Releaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Album Artist', tag.album_artist
        assert_equal 'Album Title', tag.album
        assert_equal 2021, tag.year
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        expected_comment = <<~COMMENT.chop
          Comment
          ---
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT
        assert_equal expected_comment, tag.comment
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Album Artist', tag.album_artist
        assert_equal 'Album Title', tag.album
        assert_equal 2021, tag.year
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        expected_comment = <<~COMMENT.chop
          Comment
          ---
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT
        assert_equal expected_comment, tag.comment
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Album Artist', tag.album_artist
        assert_equal 'Album Title', tag.album
        assert_equal 2021, tag.year
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        expected_comment = <<~COMMENT.chop
          Comment
          ---
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT
        assert_equal expected_comment, tag.comment
      end
    end
  end

  describe 'without album' do
    before do
      assert_nil @track.album
    end

    it 'does not set any album specific tags' do
      @track.artist = 'Track Artist'
      @track.title = 'Track Title'
      @track.rank = 3
      @track.comment = 'Comment'
      tagger = Audiofeeler::Releaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_nil tag.album_artist
        assert_nil tag.album
        assert_nil tag.year
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        assert_equal 'Comment', tag.comment
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_nil tag.album_artist
        assert_nil tag.album
        assert_nil tag.year
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        assert_equal 'Comment', tag.comment
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @track.generate(tmp_dir, format: Audiofeeler::Releaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_nil tag.album_artist
        assert_nil tag.album
        assert_nil tag.year
        assert_equal 'Track Artist', tag.artist
        assert_equal 'Track Title', tag.title
        assert_equal 3, tag.rank
        assert_equal 'Comment', tag.comment
      end
    end
  end
end
