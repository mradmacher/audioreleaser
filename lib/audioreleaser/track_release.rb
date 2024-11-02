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

    # rubocop:disable Metrics/AbcSize
    def tags
      Audioreleaser::Tags.new(
        album: track.album&.title,
        album_artist: track.album&.artist,
        artist: track.artist || track.album&.artist,
        year: track.album&.year,
        title: track.title,
        rank: track.rank,
        comment: build_extended_comment(track.comment, license: license, contact: contact),
      )
    end
    # rubocop:enable Metrics/AbcSize

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
        quality: quality,
      )
      tagger.apply_to(output_path, tags: tags)
    end

    def file_basename
      value = track.rank ? "#{Kernel.format('%02d', track.rank)}-" : ''
      value + Audioreleaser::Encoder.parameterize(track.title).to_s
    end

    def build_extended_comment(comment, license: nil, contact: nil)
      components = []
      components << comment if comment
      components << '---' if !components.empty? && (license || contact)
      components << license.to_s if license
      components << contact.to_s if contact
      components.join("\n")
    end

    def tagger
      @tagger ||= Audioreleaser::Tagger.new
    end
  end
end
