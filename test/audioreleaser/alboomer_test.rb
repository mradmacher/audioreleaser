# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::Alboomer do
  it 'works' do
    yaml = <<-YAML_TEXT
      title: Najgorsze hity
      artist: Jęczące brzękodźwięki
      year: 2025
      tracks:
        - title: Trata bam
          comment: Powstało, kiedy czasu było mało
        - title: Trata tam
          artist: Świszczące fujary
        - title: Trata bum
    YAML_TEXT

    album = Audioreleaser::Alboomer.load_album(yaml)
    assert_equal 'Jęczące brzękodźwięki', album.artist
    assert_equal 'Najgorsze hity', album.title
    assert_equal 2025, album.year
    assert_equal 3, album.tracks.size

    track = album.tracks[0]
    assert_equal 1, track.rank
    assert_equal 'Trata bam', track.title
    assert_nil track.artist
    assert_equal 'Powstało, kiedy czasu było mało', track.comment

    track = album.tracks[1]
    assert_equal 2, track.rank
    assert_equal 'Trata tam', track.title
    assert_equal 'Świszczące fujary', track.artist
    assert_nil track.comment

    track = album.tracks[2]
    assert_equal 3, track.rank
    assert_equal 'Trata bum', track.title
    assert_nil track.artist
    assert_nil track.comment
  end
end
