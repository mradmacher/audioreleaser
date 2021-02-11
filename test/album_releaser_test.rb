require 'test_helper'

describe Audiofeeler::AlbumReleaser do
  before do
    @artist = Audiofeeler::Artist.new
    @artist.name = 'Jęczące Brzękodźwięki'
    @album = Audiofeeler::Album.new
    @album.year = 2020
    @album.title = 'Tłuczące pokrowce jeżozwierza'
    @artist.add_album(@album)

    @tracks = 3.times.map do |i|
      Audiofeeler::Track.new.tap do |track|
        track.file = File.new(File.join(FIXTURES_DIR, "#{i + 1}.wav"))
        track.title = "Przebój numer:  #{i + 1}"
        track.rank = i + 1
        @album.add_track(track)
      end
    end

    @attachment1 = Audiofeeler::Attachment.new.tap do |attachment|
      attachment.file = File.new(File.join(FIXTURES_DIR, 'att1.jpg'))
      @album.add_attachment(attachment)
    end
    @attachment2 = Audiofeeler::Attachment.new.tap do |attachment|
      attachment.file = File.new(File.join(FIXTURES_DIR, 'att2.pdf'))
      @album.add_attachment(attachment)
    end
    @attachment3 = Audiofeeler::Attachment.new.tap do |attachment|
      attachment.file = File.new(File.join(FIXTURES_DIR, 'att3.txt'))
      @album.add_attachment(attachment)
    end
  end

  it 'creates ogg release' do
    releaser = Audiofeeler::AlbumReleaser.new(@album)
    releaser.with_release(Audiofeeler::Release::OGG) do |file_path|
      check_album_release(@album, Audiofeeler::Release::OGG, file_path)
    end
  end

  it 'creates flac release' do
    releaser = Audiofeeler::AlbumReleaser.new(@album)
    releaser.with_release(Audiofeeler::Release::FLAC) do |file_path|
      check_album_release(@album, Audiofeeler::Release::FLAC, file_path)
    end
  end

  it 'creates mp3 release' do
    releaser = Audiofeeler::AlbumReleaser.new(@album)
    releaser.with_release(Audiofeeler::Release::MP3) do |file_path|
      check_album_release(@album, Audiofeeler::Release::MP3, file_path)
    end
  end

  def check_album_release(album, format, file_path)
    artist_reference = 'Jęczące_Brzękodźwięki'
    album_reference = 'Tłuczące_pokrowce_jeżozwierza'

    assert File.exist?(file_path)
    assert_equal "#{artist_reference}-#{album_reference}-#{format}.zip", File.basename(file_path)

    Dir.mktmpdir do |tmp_dir|
      `unzip #{file_path} -d #{tmp_dir}`

      album_path = File.join(tmp_dir, artist_reference, album_reference)
      assert File.exist? album_path

      album.tracks.each_with_index do |track, i|
        expected_filename = "0#{i+1}-Przebój_numer_#{i+1}.#{format}"

        track_path = File.join(album_path, expected_filename)
        assert File.exist? track_path

        # FIXME
        # type = case release.format
        #   when Release::OGG then 'Ogg'
        #   when Release::MP3 then 'MPEG'
        #   when Release::FLAC then 'FLAC'
        # end
        # assert `file #{track_path}` =~ /#{type}/
      end

      (Audiofeeler::Release::FORMATS - [format]).each do |frmt|
        refute File.exist? File.join(album_path, "*.#{frmt}")
      end

      assert File.exist? File.join(album_path, 'att1.jpg')
      assert File.exist? File.join(album_path, 'att2.pdf')
      assert File.exist? File.join(album_path, 'att3.txt')
    end
  end
end
