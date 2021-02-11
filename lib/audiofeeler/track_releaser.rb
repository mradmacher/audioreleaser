module Audiofeeler
  class TrackReleaser
    QUALITY = {
      Release::OGG => 3,
      Release::MP3 => 6
    }.freeze
    attr_reader :track

    def initialize(track)
      @track = track
    end

    def with_release(format)
      Audiofeeler::Encoder.within_tmp_dir do |tmp_dir|
        filename = prepare_release(tmp_dir, format)
        yield File.join(tmp_dir, filename)
      end
    end

    private

    def prepare_release(working_dir, format)
      output_dir = working_dir
      generate_files(output_dir, format)
      "#{track_file_basename(track)}.#{format}"
    end

    def generate_files(output_dir, format)
      Audiofeeler::Encoder.new(track).generate_track(
        output_dir,
        track_file_basename(track),
        format: format,
        quality: QUALITY[format]
      )
    end

    def track_file_basename(track)
      Audiofeeler::Encoder.parameterize(track.title)
    end
  end
end
