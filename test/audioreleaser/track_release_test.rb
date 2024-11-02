# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::TrackRelease do
  before do
    @album = Audioreleaser::Album.new
    @track = Audioreleaser::Track.new(
      file: File.new(File.join(FIXTURES_DIR, '1.wav')),
      title: 'Ta-bum-ta-bam',
    )
    @release = Audioreleaser::TrackRelease.new(@track)
  end

  describe 'file name without rank tag' do
    before do
      @track.rank = nil
    end

    it 'creates ogg release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
        assert File.exist? file_path
        assert_equal 'Tabumtabam.ogg', File.basename(file_path)
        assert `file #{file_path}` =~ /Ogg/
      end
    end

    it 'creates mp3 release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
        assert File.exist? file_path
        assert_equal 'Tabumtabam.mp3', File.basename(file_path)
        assert `file #{file_path}` =~ /MPEG/
      end
    end

    it 'creates flac release with title only in name' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
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
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
        assert File.exist? file_path
        assert_equal '02-Tabumtabam.ogg', File.basename(file_path)
        assert `file #{file_path}` =~ /Ogg/
      end
    end

    it 'creates mp3 release with title prefixed by rank' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
        assert File.exist? file_path
        assert_equal '02-Tabumtabam.mp3', File.basename(file_path)
        assert `file #{file_path}` =~ /MPEG/
      end
    end

    it 'creates flac release with title prefixed by rank' do
      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
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
      tagger = Audioreleaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Jęczące Brzękodźwięki', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end
    end

    it 'uses artist name from track if set' do
      @track.artist = 'Świszczące Fujary'
      @album.artist = 'Jęczące Brzękodźwięki'
      tagger = Audioreleaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
        tag = tagger.fetch_from(file_path)
        assert_equal 'Świszczące Fujary', tag.artist
        assert_equal 'Jęczące Brzękodźwięki', tag.album_artist
      end
    end

    it 'sets all tags from album and track' do
      @album.artist = 'Album Artist'
      @album.year = 2021
      @album.title = 'Album Title'
      @track.artist = 'Track Artist'
      @track.title = 'Track Title'
      @track.rank = 3
      @track.comment = 'Comment'
      @release.license = Audioreleaser::License::CC_BY_40
      @release.contact = 'http://example.com'
      tagger = Audioreleaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
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
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
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
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
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
      tagger = Audioreleaser::Tagger.new

      Dir.mktmpdir do |tmp_dir|
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
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
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
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
        file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
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

  describe 'comment tag' do
    before do
      @track.comment = 'Jeden z najlepszych utworów jakie powstały'
    end

    it 'adds license to comment tag' do
      @release.license = Audioreleaser::License::CC_BY_40
      comment = @release.tags.comment
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          Creative Commons Attribution 4.0 International License
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'adds webpage to comment tag' do
      @release.contact = 'http://example.com'
      comment = @release.tags.comment
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'adds licence and webpage to comment tag' do
      @release.contact = 'http://example.com'
      @release.license = Audioreleaser::License::CC_BY_40
      comment = @release.tags.comment
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'sets licence and webpage as comment tag if track has no comment' do
      @track.comment = nil
      @release.contact = 'http://example.com'
      @release.license = Audioreleaser::License::CC_BY_40
      comment = @release.tags.comment
      expected_comment =
        <<~COMMENT.chop
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end
  end
end
