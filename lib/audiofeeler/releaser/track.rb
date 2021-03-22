# frozen_string_literal: true

module Audiofeeler
  module Releaser
    # Encodes and tags single audio file.
    class Track
      QUALITY = {
        Encoder::OGG => 3,
        Encoder::MP3 => 6
      }.freeze

      attr_accessor :file, :title, :rank, :comment, :artist, :album

      def initialize(file, **args)
        @file = file
        @title = args[:title]
        @rank = args[:rank]
        @comment = args[:comment]
        @artist = args[:artist]
      end

      def generate(output_dir, format:, quality: nil)
        filename = prepare_release(output_dir, format, quality || QUALITY[format.to_sym])
        File.join(output_dir, filename)
      end

      def with_release(format)
        Audiofeeler::Releaser::Encoder.within_tmp_dir do |tmp_dir|
          yield generate(tmp_dir, format: format)
        end
      end

      private

      def prepare_release(working_dir, format, quality)
        output_dir = working_dir
        generate_files(output_dir, format, quality)
        "#{file_basename}.#{format}"
      end

      def generate_files(output_dir, format, quality)
        output_path = Audiofeeler::Releaser::Encoder.new(file).generate_track(
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
        Audiofeeler::Releaser::Tag.new.tap do |t|
          t.album = album&.title
          t.album_artist = album&.artist
          t.artist = artist || album&.artist
          t.year = album&.year
          t.title = title
          t.rank = rank
          t.comment = Audiofeeler::Releaser::Tag.build_extended_comment(
            comment, license: album&.license, contact: album&.contact
          )
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      def file_basename
        value = rank ? "#{Kernel.format('%02d', rank)}-" : ''
        value + Audiofeeler::Releaser::Encoder.parameterize(title).to_s
      end

      def tagger
        @tagger ||= Audiofeeler::Releaser::Tagger.new
      end
    end
  end
end
