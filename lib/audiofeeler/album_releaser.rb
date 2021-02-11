require 'shell_whisperer'

module Audiofeeler
  class AlbumReleaser
    QUALITY = {
      Release::OGG => 10,
      Release::MP3 => 0
    }.freeze
    attr_reader :album

    def initialize(album)
      @album = album
    end

    def with_release(format)
      Audiofeeler::Encoder.within_tmp_dir do |working_dir|
        filename = prepare_release(working_dir, format)
        yield File.join(working_dir, filename)
      end
    end

    private

    def prepare_release(working_dir, format)
      album_name = Audiofeeler::Encoder.parameterize(album.title)
      artist_name = Audiofeeler::Encoder.parameterize(album.artist.name)

      album_dir = File.join(artist_name, album_name)
      output_dir = File.join(working_dir, album_dir)

      generate_files(output_dir, format)
      copy_attachments(output_dir)

      archive_name = "#{artist_name}-#{album_name}-#{format}.zip"
      make_archive(working_dir, archive_name)

      archive_name
    end

    def generate_files(output_dir, format)
      album.tracks.each do |track|
        Audiofeeler::Encoder.new(track).generate_track(
          output_dir,
          track_file_basename(track),
          format: format,
          quality: QUALITY[format]
        )
      end
    end

    def copy_attachments(output_dir)
      album.attachments.each do |attachment|
        FileUtils.cp(attachment.file.path, output_dir)
      end
    end

    def make_archive(working_dir, archive_name)
      pwd = Dir.pwd
      Dir.chdir working_dir
      ShellWhisperer.run("zip -rm #{archive_name} * ")
      Dir.chdir pwd
    end

    def track_file_basename(track)
      "#{Kernel.format('%02d', track.rank)}-#{Audiofeeler::Encoder.parameterize(track.title)}"
    end
  end
end
