# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::AlbumRelease do
  before do
    @album = Audioreleaser::Album.new(
      title: 'Tłuczące pokrowce jeżozwierza',
      artist: 'Jęczące Brzękodźwięki',
      year: 2020,
    )
    3.times.map do |i|
      @album.add_track(
        file: File.new(File.join(FIXTURES_DIR, "#{i + 1}.wav")),
        title: "Przebój numer:  #{i + 1}",
      )
    end

    @release = Audioreleaser::AlbumRelease.new(@album)
    @release.add_attachment(File.new(File.join(FIXTURES_DIR, 'att1.jpg')))
    @release.add_attachment(File.new(File.join(FIXTURES_DIR, 'att2.pdf')))
    @release.add_attachment(File.new(File.join(FIXTURES_DIR, 'att3.txt')))
  end

  it 'does not remove any files if input dir as output dir' do
    Dir.mktmpdir do |tmp_dir|
      @album.tracks.each do |track|
        FileUtils.cp(track.file, tmp_dir)
        track.file = File.new(File.join(tmp_dir, File.basename(track.file)))
      end
      expected_files = @album.tracks.map(&:file).map(&:path)
      found_files = Dir["#{tmp_dir}/*"]

      expected_files.each { assert_includes found_files, _1 }

      file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
      check_album_release(Audioreleaser::Encoder::FLAC, file_path)

      found_files = Dir["#{tmp_dir}/*"]
      expected_files.each { assert_includes found_files, _1 }
    end
  end

  it 'creates ogg release' do
    Dir.mktmpdir do |tmp_dir|
      file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::OGG)
      check_album_release(Audioreleaser::Encoder::OGG, file_path)
    end
  end

  it 'creates flac release' do
    Dir.mktmpdir do |tmp_dir|
      file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::FLAC)
      check_album_release(Audioreleaser::Encoder::FLAC, file_path)
    end
  end

  it 'creates mp3 release' do
    Dir.mktmpdir do |tmp_dir|
      file_path = @release.generate(tmp_dir, format: Audioreleaser::Encoder::MP3)
      check_album_release(Audioreleaser::Encoder::MP3, file_path)
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

      (Audioreleaser::Encoder::FORMATS - [format]).each do |frmt|
        refute File.exist? File.join(album_path, "*.#{frmt}")
      end

      assert File.exist? File.join(album_path, 'att1.jpg')
      assert File.exist? File.join(album_path, 'att2.pdf')
      assert File.exist? File.join(album_path, 'att3.txt')
    end
  end
end
