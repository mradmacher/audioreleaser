# frozen_string_literal: true

require 'test_helper'

describe Audiofeeler::Releaser::Album do
  before do
    @album = Audiofeeler::Releaser::Album.new(
      title: 'Tłuczące pokrowce jeżozwierza',
      artist: 'Jęczące Brzękodźwięki',
      year: 2020
    )
    3.times.map do |i|
      @album.add_track(
        Audiofeeler::Releaser::Track.new(
          File.new(File.join(FIXTURES_DIR, "#{i + 1}.wav")),
          title: "Przebój numer:  #{i + 1}",
          rank: i + 1
        )
      )
    end

    @album.add_attachment(File.new(File.join(FIXTURES_DIR, 'att1.jpg')))
    @album.add_attachment(File.new(File.join(FIXTURES_DIR, 'att2.pdf')))
    @album.add_attachment(File.new(File.join(FIXTURES_DIR, 'att3.txt')))
  end

  it 'assigns album to track' do
    refute_nil @album.tracks[0].album
    refute_nil @album.tracks[1].album
    refute_nil @album.tracks[2].album
  end

  it 'creates ogg release' do
    @album.with_release(Audiofeeler::Releaser::Encoder::OGG) do |file_path|
      check_album_release(Audiofeeler::Releaser::Encoder::OGG, file_path)
    end
  end

  it 'creates flac release' do
    @album.with_release(Audiofeeler::Releaser::Encoder::FLAC) do |file_path|
      check_album_release(Audiofeeler::Releaser::Encoder::FLAC, file_path)
    end
  end

  it 'creates mp3 release' do
    @album.with_release(Audiofeeler::Releaser::Encoder::MP3) do |file_path|
      check_album_release(Audiofeeler::Releaser::Encoder::MP3, file_path)
    end
  end

  def check_album_release(format, file_path)
    artist_reference = 'Jęczące_Brzękodźwięki'
    album_reference = 'Tłuczące_pokrowce_jeżozwierza'

    assert File.exist?(file_path)
    assert_equal "#{artist_reference}-#{album_reference}-#{format}.zip", File.basename(file_path)

    Dir.mktmpdir do |tmp_dir|
      `unzip #{file_path} -d #{tmp_dir}`

      album_path = File.join(tmp_dir, artist_reference, album_reference)
      assert File.exist? album_path

      3.times do |i|
        expected_filename = "0#{i + 1}-Przebój_numer_#{i + 1}.#{format}"

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

      (Audiofeeler::Releaser::Encoder::FORMATS - [format]).each do |frmt|
        refute File.exist? File.join(album_path, "*.#{frmt}")
      end

      assert File.exist? File.join(album_path, 'att1.jpg')
      assert File.exist? File.join(album_path, 'att2.pdf')
      assert File.exist? File.join(album_path, 'att3.txt')
    end
  end
end
