# frozen_string_literal: true

require 'test_helper'

describe Audiofeeler::Releaser::Tagger do
  before do
    @tmp_dir = Dir.mktmpdir
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.flac'), @tmp_dir)
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.ogg'), @tmp_dir)
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.mp3'), @tmp_dir)
    @flac_path = File.join(@tmp_dir, 'test.flac')
    @ogg_path = File.join(@tmp_dir, 'test.ogg')
    @mp3_path = File.join(@tmp_dir, 'test.mp3')

    @tag = Audiofeeler::Releaser::Tag.new
    @tag.album = 'Tłuczące pokrowce jeżozwierza'
    @tag.artist = 'Jęczące Brzękodźwięki'
    @tag.album_artist = 'Różni artyści'
    @tag.year = 2021
    @tag.title = 'Przebój'
    @tag.rank = 2
    @tag.comment = <<~COMMENT.chop
      Jeden z najlepszych utworów jakie powstały
      ---
      http://example.com
    COMMENT

    @tagger = Audiofeeler::Releaser::Tagger.new
  end

  after do
    FileUtils.remove_entry_secure(@tmp_dir)
  end

  def fetch_tags(track_path)
    case File.extname(track_path)
    when '.ogg'
      TagLib::Ogg::Vorbis::File.open(track_path) do |file|
        yield file.tag
      end
    when '.mp3'
      TagLib::MPEG::File.open(track_path) do |file|
        yield file.id3v2_tag
      end
    when '.flac'
      TagLib::FLAC::File.open(track_path) do |file|
        yield file.xiph_comment
      end
    else
      raise
    end
  end

  it 'sets artist tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal 'Jęczące Brzękodźwięki', found.artist }
    assert_equal 'Jęczące Brzękodźwięki', @tagger.fetch_from(@flac_path).artist

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal 'Jęczące Brzękodźwięki', found.artist }
    assert_equal 'Jęczące Brzękodźwięki', @tagger.fetch_from(@ogg_path).artist

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal 'Jęczące Brzękodźwięki', found.artist }
    assert_equal 'Jęczące Brzękodźwięki', @tagger.fetch_from(@mp3_path).artist
  end

  it 'sets album tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal 'Tłuczące pokrowce jeżozwierza', found.album }
    assert_equal 'Tłuczące pokrowce jeżozwierza', @tagger.fetch_from(@flac_path).album

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal 'Tłuczące pokrowce jeżozwierza', found.album }
    assert_equal 'Tłuczące pokrowce jeżozwierza', @tagger.fetch_from(@ogg_path).album

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal 'Tłuczące pokrowce jeżozwierza', found.album }
    assert_equal 'Tłuczące pokrowce jeżozwierza', @tagger.fetch_from(@mp3_path).album
  end

  it 'sets title tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal 'Przebój', found.title }
    assert_equal 'Przebój', @tagger.fetch_from(@flac_path).title

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal 'Przebój', found.title }
    assert_equal 'Przebój', @tagger.fetch_from(@ogg_path).title

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal 'Przebój', found.title }
    assert_equal 'Przebój', @tagger.fetch_from(@mp3_path).title
  end

  it 'sets year tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal 2021, found.year }
    assert_equal 2021, @tagger.fetch_from(@flac_path).year

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal 2021, found.year }
    assert_equal 2021, @tagger.fetch_from(@ogg_path).year

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal 2021, found.year }
    assert_equal 2021, @tagger.fetch_from(@mp3_path).year
  end

  it 'sets track number tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal 2, found.track }
    assert_equal 2, @tagger.fetch_from(@flac_path).rank

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal 2, found.track }
    assert_equal 2, @tagger.fetch_from(@ogg_path).rank

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal 2, found.track }
    assert_equal 2, @tagger.fetch_from(@mp3_path).rank
  end

  it 'adds comment tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) { |found| assert_equal @tag.comment, found.comment }
    assert_equal @tag.comment, @tagger.fetch_from(@flac_path).comment

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) { |found| assert_equal @tag.comment, found.comment }
    assert_equal @tag.comment, @tagger.fetch_from(@ogg_path).comment

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) { |found| assert_equal @tag.comment, found.comment }
    assert_equal @tag.comment, @tagger.fetch_from(@mp3_path).comment
  end

  it 'sets album artist tag' do
    @tagger.apply_to(@flac_path, tag: @tag)
    fetch_tags(@flac_path) do |found|
      assert_equal ['Różni artyści'], found.field_list_map['ALBUMARTIST']
    end
    assert_equal 'Różni artyści', @tagger.fetch_from(@flac_path).album_artist

    @tagger.apply_to(@ogg_path, tag: @tag)
    fetch_tags(@ogg_path) do |found|
      assert_equal ['Różni artyści'], found.field_list_map['ALBUMARTIST']
    end
    assert_equal 'Różni artyści', @tagger.fetch_from(@ogg_path).album_artist

    @tagger.apply_to(@mp3_path, tag: @tag)
    fetch_tags(@mp3_path) do |found|
      tpe2 = found.frame_list('TPE2').first
      assert tpe2.is_a? TagLib::ID3v2::TextIdentificationFrame
      assert_equal 'Różni artyści', tpe2.to_s
    end
    assert_equal 'Różni artyści', @tagger.fetch_from(@mp3_path).album_artist
  end

  it 'does not set missing tags' do
    tag = Audiofeeler::Releaser::Tag.new
    @tagger.apply_to(@flac_path, tag: tag)
    fetch_tags(@flac_path) do |found|
      assert found.artist.empty?
      assert found.album.empty?
      assert found.title.empty?
      assert found.comment.empty?
      assert_equal 0, found.track
      assert_equal 0, found.year
    end
    found_tag = @tagger.fetch_from(@flac_path)
    assert_nil found_tag.artist
    assert_nil found_tag.album_artist
    assert_nil found_tag.album
    assert_nil found_tag.title
    assert_nil found_tag.comment
    assert_nil found_tag.rank
    assert_nil found_tag.year

    @tagger.apply_to(@ogg_path, tag: tag)
    fetch_tags(@ogg_path) do |found|
      assert found.artist.empty?
      assert found.album.empty?
      assert found.title.empty?
      assert found.comment.empty?
      assert_equal 0, found.track
      assert_equal 0, found.year
    end
    found_tag = @tagger.fetch_from(@ogg_path)
    assert_nil found_tag.artist
    assert_nil found_tag.album_artist
    assert_nil found_tag.album
    assert_nil found_tag.title
    assert_nil found_tag.comment
    assert_nil found_tag.rank
    assert_nil found_tag.year

    @tagger.apply_to(@mp3_path, tag: tag)
    fetch_tags(@mp3_path) do |found|
      assert found.artist.empty?
      assert found.album.empty?
      assert found.title.empty?
      assert found.comment.empty?
      assert_equal 0, found.track
      assert_equal 0, found.year
    end
    found_tag = @tagger.fetch_from(@mp3_path)
    assert_nil found_tag.artist
    assert_nil found_tag.album_artist
    assert_nil found_tag.album
    assert_nil found_tag.title
    assert_nil found_tag.comment
    assert_nil found_tag.rank
    assert_nil found_tag.year
  end
end
