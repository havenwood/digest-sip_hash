# frozen_string_literal: true

require_relative 'helper'

describe Digest::SipHash do
  describe Digest::SipHash13 do
    it 'is the default' do
      assert_equal Digest::SipHash.hexdigest(''), Digest::SipHash13.hexdigest('')
    end

    it 'produces the correct hash' do
      assert_equal 'd1fba762150c532c', Digest::SipHash13.hexdigest('')
      assert_equal 'abac0158050fc4dc', Digest::SipHash13.hexdigest('', key: 16.times.map(&:chr).join)
      assert_equal 'ce31007e34130c0a', Digest::SipHash13.hexdigest('digest-sip_hash')
      assert_equal '1b47c0cc4dd21f05', Digest::SipHash13.hexdigest('x' * 1_000)
    end
  end

  describe Digest::SipHash24 do
    it 'produces the correct hash' do
      assert_equal '1e924b9d737700d7', Digest::SipHash24.hexdigest('')
      assert_equal '726fdb47dd0e0e31', Digest::SipHash24.hexdigest('', key: 16.times.map(&:chr).join)
      assert_equal '4b5cd6bb2500bc8f', Digest::SipHash24.hexdigest('digest-sip_hash')
      assert_equal 'a07a230346e2656b', Digest::SipHash24.hexdigest('x' * 1_000)
    end
  end

  describe 'arbitrary rounds other than 1-3 and 2-4' do
    it 'produces the correct hash' do
      assert_equal '3204eeb59b3cccdd', Digest::SipHash.new(1, 2).hexdigest('')
      assert_equal 'cea28b51565c12e2', Digest::SipHash.new(1, 2, key: 16.times.map(&:chr).join).hexdigest('')
      assert_equal '95772adebda3f3f0', Digest::SipHash.new(3, 5).hexdigest('')
      assert_equal 'f344baf915afc13a', Digest::SipHash.new(3, 5).hexdigest('x' * 1_000)
    end
  end
end
