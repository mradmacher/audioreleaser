# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::Track do
  before do
    @album = Audioreleaser::Album.new(title: 'Album Title')
  end

  it 'assigns all attributes' do
    track = Audioreleaser::Track.new(
      file: File.new(File.join(FIXTURES_DIR, '1.wav')),
      title: 'Ta-bum-ta-bam',
      artist: 'Track Artist',
      rank: 3,
      comment: 'Comment',
      album: @album,
    )

    assert_equal 'Track Artist', track.artist
    assert_equal 'Ta-bum-ta-bam', track.title
    assert_equal 3, track.rank
    assert_equal 'Comment', track.comment
    assert_equal @album, track.album
    assert_equal 'Album Title', track.album.title
  end
end
