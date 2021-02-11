require 'test_helper'

describe Audiofeeler::Tagger do
  before do
    @tmp_dir = Dir.mktmpdir
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.flac'), @tmp_dir)
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.ogg'), @tmp_dir)
    FileUtils.cp(File.join(FIXTURES_DIR, 'test.mp3'), @tmp_dir)
    @flac_path = File.join(@tmp_dir, 'test.flac')
    @ogg_path = File.join(@tmp_dir, 'test.ogg')
    @mp3_path = File.join(@tmp_dir, 'test.mp3')

    @artist = Audiofeeler::Artist.new
    @artist.name = 'Jęczące Brzękodźwięki'

    @album = Audiofeeler::Album.new
    @album.artist = @artist
    @album.year = 2020
    @album.title = 'Tłuczące pokrowce jeżozwierza'
    @album.license = Audiofeeler::License::CC_BY_40

    @track = Audiofeeler::Track.new
    @track.album = @album
    @track.title = 'Przebój'
    @track.rank = 2
    @track.comment = 'Jeden z najlepszych utworów jakie powstały'

    @tagger = Audiofeeler::Tagger.new(@track)
  end

  after do
    FileUtils.remove_entry_secure(@tmp_dir, force = true)
  end

  it 'sets artist tag' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal @artist.name, found.artist }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal @artist.name, found.artist }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal @artist.name, found.artist }
  end

  it 'sets album tag' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal @album.title, found.album }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal @album.title, found.album }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal @album.title, found.album }
  end

  it 'sets title tag' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal @track.title, found.title }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal @track.title, found.title }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal @track.title, found.title }
  end

  it 'sets year tag' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal @album.year, found.year }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal @album.year, found.year }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal @album.year, found.year }
  end

  it 'does not set year tag if year missing' do
    @album.year = nil
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal 0, found.year }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal 0, found.year }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal 0, found.year }
  end

  it 'sets track number tag' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal @track.rank, found.track }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal @track.rank, found.track }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal @track.rank, found.track }
  end

  it 'does not set track number tag if track number missing' do
    @track.rank = nil
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal 0, found.track }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal 0, found.track }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal 0, found.track }
  end

  it 'adds license to comment tag' do
    @album.license = Audiofeeler::License::CC_BY_40
    expected_comment =
      <<~COMMENT.chop
        Jeden z najlepszych utworów jakie powstały
        ---
        Creative Commons Attribution 4.0 International License
      COMMENT

    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal expected_comment, found.comment }
  end

  it 'adds webpage to comment tag' do
    @album.license = nil
    @artist.webpage = 'http://example.com'
    expected_comment =
      <<~COMMENT.chop
        Jeden z najlepszych utworów jakie powstały
        ---
        http://example.com
      COMMENT

    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal expected_comment, found.comment }
  end

  it 'adds licence and webpage to comment tag' do
    @album.license = Audiofeeler::License::CC_BY_40
    @artist.webpage = 'http://example.com'
    expected_comment =
      <<~COMMENT.chop
        Jeden z najlepszych utworów jakie powstały
        ---
        Creative Commons Attribution 4.0 International License
        http://example.com
      COMMENT

    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal expected_comment, found.comment }
  end

  it 'sets licence and webpage as comment tag if track has no comment' do
    @album.license = Audiofeeler::License::CC_BY_40
    @artist.webpage = 'http://example.com'
    @track.comment = nil
    expected_comment =
      <<~COMMENT.chop
        Creative Commons Attribution 4.0 International License
        http://example.com
      COMMENT

    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) { |found| assert_equal expected_comment, found.comment }

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) { |found| assert_equal expected_comment, found.comment }
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

  it 'sets album artist equal to artist name' do
    @tagger.apply_to(@flac_path)
    fetch_tags(@flac_path) do |found|
      assert_equal @artist.name, found.artist
      assert_equal [@artist.name], found.field_list_map['ALBUMARTIST']
    end

    @tagger.apply_to(@ogg_path)
    fetch_tags(@ogg_path) do |found|
      assert_equal @artist.name, found.artist
      assert_equal [@artist.name], found.field_list_map['ALBUMARTIST']
    end

    @tagger.apply_to(@mp3_path)
    fetch_tags(@mp3_path) do |found|
      assert_equal @artist.name, found.artist
      tpe2 = found.frame_list('TPE2').first
      assert tpe2.is_a? TagLib::ID3v2::TextIdentificationFrame
      assert_equal @artist.name, tpe2.to_s
    end
  end

  it 'uses artist name from track if set' do
    @track.artist_name = 'Świszczące Fujary'

    path = File.join(@tmp_dir, 'test.flac')
    @tagger.apply_to(path)
    fetch_tags(path) do |found|
      assert_equal @track.artist_name, found.artist
      assert_equal [@artist.name], found.field_list_map['ALBUMARTIST']
    end

    path = File.join(@tmp_dir, 'test.ogg')
    @tagger.apply_to(path)
    fetch_tags(path) do |found|
      assert_equal @track.artist_name, found.artist
      assert_equal [@artist.name], found.field_list_map['ALBUMARTIST']
    end

    path = File.join(@tmp_dir, 'test.mp3')
    @tagger.apply_to(path)
    fetch_tags(path) do |found|
      assert_equal @track.artist_name, found.artist
      tpe2 = found.frame_list('TPE2').first
      assert tpe2.is_a? TagLib::ID3v2::TextIdentificationFrame
      assert_equal @artist.name, tpe2.to_s
    end
  end
end
