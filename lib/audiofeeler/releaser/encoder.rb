# frozen_string_literal: true

require 'shell_whisperer'

module Audiofeeler
  module Releaser
    # Encodes an audio file to specified audio format.
    class Encoder
      OGG = :ogg
      MP3 = :mp3
      FLAC = :flac

      FORMATS = [
        OGG,
        MP3,
        FLAC
      ].freeze

      attr_reader :file

      def initialize(file)
        @file = file
      end

      def self.within_tmp_dir(&block)
        Dir.mktmpdir(&block)
      end

      def self.parameterize(name)
        name.gsub(/[[:punct:]]/, '').gsub(/[[:space:]]+/, '_')
      end

      def generate_track(output_dir, output_basename, format:, quality:)
        raise 'unknown format' unless %w[flac ogg mp3].include?(format.to_s)

        FileUtils.mkdir_p(output_dir)
        output_path = File.join(output_dir, "#{output_basename}.#{format}")

        case format
        when FLAC
          gen_flac(file.path, output_path)
        when OGG
          gen_ogg(file.path, output_path, quality)
        when MP3
          gen_mp3(file.path, output_path, quality)
        end
        output_path
      end

      private

      def gen_ogg(input, output, quality)
        ShellWhisperer.run("oggenc -Q #{input} -q #{quality} -o #{output}")
      end

      def gen_mp3(input, output, quality)
        ShellWhisperer.run("lame --quiet -V #{quality} #{input} #{output}")
      end

      def gen_flac(input, output)
        ShellWhisperer.run("flac --silent #{input} -o #{output}")
      end
    end
  end
end
