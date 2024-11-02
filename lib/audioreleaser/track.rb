# frozen_string_literal: true

module Audioreleaser
  # Describes track properties.
  Track = Struct.new(:file, :title, :rank, :comment, :artist, :album)
end
