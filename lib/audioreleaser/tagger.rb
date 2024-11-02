# frozen_string_literal: true

require 'taglib'

module Audioreleaser
  # Applies tags to an audio file.
  class Tagger
    def apply_to(file_path, tags:)
      for_file(file_path) do |file_tags|
        apply_common(file_tags, tags) if file_tags
        case file_tags
        when TagLib::Ogg::XiphComment
          apply_xiph_specific(file_tags, tags)
        when TagLib::ID3v2::Tag
          apply_id3v2_specific(file_tags, tags)
        end
      end
    end

    def fetch_from(file_path)
      with_file_tag(file_path) do |file_tag|
        read_tags(file_tag)
      end
    end

    private

    def with_file_tag(file_path)
      case File.extname(file_path)
      when '.ogg'
        TagLib::Ogg::Vorbis::File.open(file_path) do |file|
          yield file.tag
        end
      when '.mp3'
        TagLib::MPEG::File.open(file_path) do |file|
          yield file.id3v2_tag
        end
      when '.flac'
        TagLib::FLAC::File.open(file_path) do |file|
          yield file.xiph_comment
        end
      else
        raise 'unknown file format'
      end
    end

    def read_tags(file_tags)
      Tags.new(
        album: value_or_nil(file_tags.album),
        artist: value_or_nil(file_tags.artist),
        title: value_or_nil(file_tags.title),
        rank: nonzero_or_nil(file_tags.track),
        year: nonzero_or_nil(file_tags.year),
        comment: value_or_nil(file_tags.comment),
        album_artist: value_or_nil(read_album_artist(file_tags)),
      )
    end

    def read_album_artist(file_tags)
      if file_tags.respond_to?(:field_list_map)
        file_tags.field_list_map['ALBUMARTIST']&.first
      else
        file_tags.frame_list('TPE2')&.first&.to_s
      end
    end

    def nonzero_or_nil(value)
      value.zero? ? nil : value
    end

    def value_or_nil(value)
      value.nil? || value.empty? ? nil : value
    end

    def for_file(file_path, &)
      extname = File.extname(file_path)
      case extname
      when '.ogg'
        for_ogg(file_path, &)
      when '.flac'
        for_flac(file_path, &)
      when '.mp3'
        for_mp3(file_path, &)
      end
    end

    def for_ogg(file_path)
      TagLib::Ogg::Vorbis::File.open(file_path) do |file|
        yield file.tag
        file.save
      end
    end

    def for_flac(file_path)
      TagLib::FLAC::File.open(file_path) do |file|
        yield file.xiph_comment
        file.save
      end
    end

    def for_mp3(file_path)
      TagLib::ID3v2::FrameFactory.instance.default_text_encoding = TagLib::String::UTF8
      TagLib::MPEG::File.open(file_path) do |file|
        yield file.id3v2_tag(true)
        file.save(TagLib::MPEG::File::ID3v2, true)
      end
    end

    def apply_common(file_tags, tags)
      file_tags.artist = tags.artist
      file_tags.title = tags.title
      file_tags.album = tags.album
      file_tags.year = tags.year if tags.year
      file_tags.track = tags.rank if tags.rank
      file_tags.comment = tags.comment
    end

    def apply_xiph_specific(file_tags, tags)
      file_tags.add_field('ALBUMARTIST', tags.album_artist)
    end

    def apply_id3v2_specific(file_tags, tags)
      frame = TagLib::ID3v2::TextIdentificationFrame.new('TPE2', TagLib::String::UTF8)
      frame.text = tags.album_artist
      file_tags.add_frame(frame)
    end
  end
end
