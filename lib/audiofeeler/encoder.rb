require 'shell_whisperer'

module Audiofeeler
  class Encoder
    attr_reader :track

    def initialize(track)
      @track = track
    end

    def self.within_tmp_dir
      Dir.mktmpdir do |tmp_dir|
        yield tmp_dir
      end
    end

    def self.parameterize(name)
      name.gsub(/[[:punct:]]/, '').gsub(/[[:space:]]+/, '_')
    end

    def generate_track(output_dir, output_basename, format:, quality:)
      return unless %w[flac ogg mp3].include?(format)

      FileUtils.mkdir_p(output_dir)
      output_path = File.join(output_dir, "#{output_basename}.#{format}")

      case format
      when 'flac'
        gen_flac(track.file.path, output_path)
      when 'ogg'
        gen_ogg(track.file.path, output_path, quality)
      when 'mp3'
        gen_mp3(track.file.path, output_path, quality)
      end
      Audiofeeler::Tagger.new(track).apply_to(output_path)
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
