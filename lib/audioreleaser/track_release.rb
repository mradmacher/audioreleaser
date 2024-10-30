# frozen_string_literal: true

module Audioreleaser
  # Encodes and tags single audio file.
  class TrackRelease
    QUALITY = {
      Encoder::OGG => 3,
      Encoder::MP3 => 6
    }.freeze

    attr_reader :track
    attr_accessor :license, :contact

    def initialize(track, license: nil, contact: nil)
      @track = track
      @license = license
      @contact = contact
    end

    def generate(output_dir, format:, quality: nil)
      filename = prepare_release(output_dir, format, quality || QUALITY[format.to_sym])
      File.join(output_dir, filename)
    end

    private

    def prepare_release(working_dir, format, quality)
      output_dir = working_dir
      generate_files(output_dir, format, quality)
      "#{file_basename}.#{format}"
    end

    def generate_files(output_dir, format, quality)
      output_path = Audioreleaser::Encoder.new(track.file).generate_track(
        output_dir,
        file_basename,
        format: format,
        quality: quality
      )
      tagger.apply_to(output_path, tag: tag)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def tag
      Audioreleaser::Tag.new.tap do |t|
        t.album = track.album&.title
        t.album_artist = track.album&.artist
        t.artist = track.artist || track.album&.artist
        t.year = track.album&.year
        t.title = track.title
        t.rank = track.rank
        t.comment = Audioreleaser::Tag.build_extended_comment(
          track.comment, license: license, contact: contact
        )
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def file_basename
      value = track.rank ? "#{Kernel.format('%02d', track.rank)}-" : ''
      value + Audioreleaser::Encoder.parameterize(track.title).to_s
    end

    def tagger
      @tagger ||= Audioreleaser::Tagger.new
    end
  end
end

