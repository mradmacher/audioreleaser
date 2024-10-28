# frozen_string_literal: true

require 'test_helper'

describe Audioreleaser::Tag do
  describe '#build_extended_comment' do
    before do
      @comment = 'Jeden z najlepszych utworów jakie powstały'
      @subject = Audioreleaser::Tag
    end

    it 'adds license to comment tag' do
      comment = @subject.build_extended_comment(@comment, license: Audioreleaser::License::CC_BY_40)
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          Creative Commons Attribution 4.0 International License
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'adds webpage to comment tag' do
      comment = @subject.build_extended_comment(@comment, contact: 'http://example.com')
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'adds licence and webpage to comment tag' do
      comment = @subject.build_extended_comment(@comment, contact: 'http://example.com',
                                                          license: Audioreleaser::License::CC_BY_40)
      expected_comment =
        <<~COMMENT.chop
          Jeden z najlepszych utworów jakie powstały
          ---
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end

    it 'sets licence and webpage as comment tag if track has no comment' do
      comment = @subject.build_extended_comment(nil, contact: 'http://example.com',
                                                     license: Audioreleaser::License::CC_BY_40)
      expected_comment =
        <<~COMMENT.chop
          Creative Commons Attribution 4.0 International License
          http://example.com
        COMMENT

      assert_equal expected_comment, comment
    end
  end
end
