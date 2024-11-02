# frozen_string_literal: true

module Audioreleaser
  # Collection of tags for an audio file.
  Tags = Struct.new(
    :album,
    :artist,
    :album_artist,
    :title,
    :rank,
    :year,
    :comment,
  )
end
