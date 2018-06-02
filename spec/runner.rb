# frozen_string_literal: true

require_relative 'helper'

describe Digest::SipHash do
  describe Digest::SipHash13 do
    it 'is the default' do
      assert_equal Digest::SipHash.hexdigest(''), Digest::SipHash13.hexdigest('')
    end

    it 'is the correct hexdigest' do
      assert_equal 'd1fba762150c532c', Digest::SipHash13.hexdigest('')
      assert_equal '8264ceeccb16bcbe', Digest::SipHash13.hexdigest('siphash')
      assert_equal 'ce31007e34130c0a', Digest::SipHash13.hexdigest('digest-sip_hash')
      assert_equal '1b47c0cc4dd21f05', Digest::SipHash13.hexdigest('x' * 1_000)
    end

    describe 'with a key' do
      let :key do
        16.times.map(&:chr).join
      end

      it 'is the correct hexdigest' do
        assert_equal 'abac0158050fc4dc', Digest::SipHash13.hexdigest('', key: key)
        assert_equal 'd5518fe19f28c745', Digest::SipHash13.hexdigest('siphash', key: key)
        assert_equal '71783f159400d4b5', Digest::SipHash13.hexdigest('digest-sip_hash', key: key)
        assert_equal '2a82bb3e74675b16', Digest::SipHash13.hexdigest('x' * 1_000, key: key)
      end
    end
  end

  describe Digest::SipHash24 do
    it 'is the correct hexdigest' do
      assert_equal '1e924b9d737700d7', Digest::SipHash24.hexdigest('')
      assert_equal '59caaeb90d542464', Digest::SipHash24.hexdigest('siphash')
      assert_equal '4b5cd6bb2500bc8f', Digest::SipHash24.hexdigest('digest-sip_hash')
      assert_equal 'a07a230346e2656b', Digest::SipHash24.hexdigest('x' * 1_000)
    end

    describe 'with a key' do
      let :key do
        16.times.map(&:chr).join
      end

      it 'is the correct hexdigest' do
        assert_equal '726fdb47dd0e0e31', Digest::SipHash24.hexdigest('', key: key)
        assert_equal '882768570dc71c92', Digest::SipHash24.hexdigest('siphash', key: key)
        assert_equal '882768570dc71c92', Digest::SipHash24.hexdigest('siphash', key: key)
        assert_equal '882768570dc71c92', Digest::SipHash24.hexdigest('siphash', key: key)
      end
    end
  end

  describe 'arbitrary rounds other than 1-3 and 2-4' do
    it 'is the correct hexdigest' do
      assert_equal '3204eeb59b3cccdd', Digest::SipHash.new(1, 2).hexdigest('')
      assert_equal 'cea28b51565c12e2', Digest::SipHash.new(1, 2, key: 16.times.map(&:chr).join).hexdigest('')
      assert_equal '95772adebda3f3f0', Digest::SipHash.new(3, 5).hexdigest('')
      assert_equal 'f344baf915afc13a', Digest::SipHash.new(3, 5).hexdigest('x' * 1_000)
    end
  end
end
