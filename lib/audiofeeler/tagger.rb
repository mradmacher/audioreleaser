require 'taglib'

module Audiofeeler
  class Tagger
    attr_reader :track

    def initialize(track)
      @track = track
    end

    def apply_to(file_path)
      for_file(file_path) do |file_tags|
        apply_common(file_tags) if file_tags
        if file_tags.is_a?(TagLib::Ogg::XiphComment)
          apply_xiph_specific(file_tags)
        elsif file_tags.is_a?(TagLib::ID3v2::Tag)
          apply_id3v2_specific(file_tags)
        end
      end
    end

    private

    def for_file(file_path)
      extname = File.extname(file_path)
      case extname
      when '.ogg'
        for_ogg(file_path) { |file_tags| yield file_tags }
      when '.flac'
        for_flac(file_path) { |file_tags| yield file_tags }
      when '.mp3'
        for_mp3(file_path) { |file_tags| yield file_tags }
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

    def apply_common(file_tags)
      file_tags.artist = artist
      file_tags.title = title
      file_tags.album = album
      file_tags.year = year if year
      file_tags.track = rank if rank
      file_tags.comment = comment
    end

    def apply_xiph_specific(file_tags)
      file_tags.add_field('ALBUMARTIST', album_artist)
    end

    def apply_id3v2_specific(file_tags)
      frame = TagLib::ID3v2::TextIdentificationFrame.new('TPE2', TagLib::String::UTF8)
      frame.text = album_artist
      file_tags.add_frame(frame)
    end

    def copyright_description
      "Licensed to the public under #{license} verify at #{contact_url}"
    end

    def artist
      track.artist_name || track.album.artist.name
    end

    def album_artist
      track.album.artist.name
    end

    def album
      track.album.title
    end

    def year
      track.album.year
    end

    def title
      track.title
    end

    def rank
      track.rank
    end

    def comment
      (track.comment.dup || '').tap do |comment_value|
        if license || contact_url
          comment_value << "\n---" unless comment_value.empty?
          if license
            comment_value << "\n" unless comment_value.empty?
            comment_value << "#{license} License"
          end
          if contact_url
            comment_value << "\n" unless comment_value.empty?
            comment_value << contact_url
          end
        end
      end
    end

    def copyright
      "#{track.album.year} #{track.album.artist.name}"
    end

    def license
      track.album.license&.name
    end

    def contact_url
      track.album.artist.webpage
    end
  end
end
