# frozen_string_literal: true

require 'shell_whisperer'

module Audioreleaser
  # Releases an album encoding audio files to a specific format, tagging them and packing to a nice zip file.
  class Album
    attr_accessor :title,
                  :artist,
                  :year,
                  :license,
                  :contact
    attr_reader :tracks, :attachments, :album

    QUALITY = {
      Encoder::OGG => 10,
      Encoder::MP3 => 0
    }.freeze

    def initialize(**args)
      @title = args[:title]
      @artist = args[:artist]
      @year = args[:year]
      @license = args[:license]
      @contact = args[:contact]
      @tracks = []
      @attachments = []
    end

    def generate(output_dir, format:)
      filename = prepare_release(output_dir, format)
      File.join(output_dir, filename)
    end

    def with_release(format)
      Audioreleaser::Encoder.within_tmp_dir do |tmp_dir|
        yield generate(tmp_dir, format: format)
      end
    end

    def add_track(track)
      track.album = self
      @tracks << track
    end

    def add_attachment(file)
      @attachments << file
    end

    private

    def prepare_release(working_dir, format)
      album_name = Audioreleaser::Encoder.parameterize(title)
      artist_name = Audioreleaser::Encoder.parameterize(artist)

      album_dir = File.join(artist_name, album_name)
      output_dir = File.join(working_dir, album_dir)

      generate_files(output_dir, format)
      copy_attachments(output_dir)

      archive_name = "#{artist_name}-#{album_name}-#{format}.zip"
      make_archive(working_dir, archive_name)

      archive_name
    end

    def generate_files(output_dir, format)
      tracks.each do |track|
        track.generate(
          output_dir,
          format: format,
          quality: QUALITY[format]
        )
      end
    end

    def copy_attachments(output_dir)
      attachments.each do |attachment|
        FileUtils.cp(attachment.path, output_dir)
      end
    end

    def make_archive(working_dir, archive_name)
      pwd = Dir.pwd
      Dir.chdir working_dir
      ShellWhisperer.run("zip -rm #{archive_name} * ")
      Dir.chdir pwd
    end
  end
end
