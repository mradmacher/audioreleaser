# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::Album do
  before do
    @album = Audioreleaser::Album.new(
      title: 'Tłuczące pokrowce jeżozwierza',
      artist: 'Jęczące Brzękodźwięki',
      year: 2020
    )
    3.times.map do |i|
      @album.add_track(
        Audioreleaser::Track.new(
          File.new(File.join(FIXTURES_DIR, "#{i + 1}.wav")),
          title: "Przebój numer:  #{i + 1}",
          rank: i + 1
        )
      )
    end
  end

  it 'assigns album to track' do
    refute_nil @album.tracks[0].album
    refute_nil @album.tracks[1].album
    refute_nil @album.tracks[2].album
  end
end
