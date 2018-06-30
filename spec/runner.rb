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
      assert_equal '136ea6cf74ee7506', Digest::SipHash13.hexdigest('abc' * 10_000)
      assert_equal '8421ff50252ef54c', Digest::SipHash13.hexdigest('bulldozer')
      assert_equal '1ad2b299abf672fd', Digest::SipHash13.hexdigest('ishmael')
      assert_equal '1403853b32c9a3d7', Digest::SipHash13.hexdigest('latour')
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
        assert_equal '13152caa40a6671a', Digest::SipHash13.hexdigest('abc' * 10_000, key: key)
        assert_equal '503567849e7ff802', Digest::SipHash13.hexdigest('bulldozer', key: key)
        assert_equal '39b0f77e620b9655', Digest::SipHash13.hexdigest('ishmael', key: key)
        assert_equal '6aafa6fdaf07577a', Digest::SipHash13.hexdigest('latour', key: key)
      end
    end
  end

  describe Digest::SipHash24 do
    it 'is the correct hexdigest' do
      assert_equal '1e924b9d737700d7', Digest::SipHash24.hexdigest('')
      assert_equal '59caaeb90d542464', Digest::SipHash24.hexdigest('siphash')
      assert_equal '4b5cd6bb2500bc8f', Digest::SipHash24.hexdigest('digest-sip_hash')
      assert_equal 'a07a230346e2656b', Digest::SipHash24.hexdigest('x' * 1_000)
      assert_equal '2e05ad971738666e', Digest::SipHash24.hexdigest('abc' * 10_000)
      assert_equal '35e35e884f56688f', Digest::SipHash24.hexdigest('bulldozer')
      assert_equal '98585807dafda42b', Digest::SipHash24.hexdigest('ishmael')
      assert_equal '3802759a0e659a96', Digest::SipHash24.hexdigest('latour')
    end

    describe 'with a key' do
      let :key do
        16.times.map(&:chr).join
      end

      it 'is the correct hexdigest' do
        assert_equal '726fdb47dd0e0e31', Digest::SipHash24.hexdigest('', key: key)
        assert_equal '882768570dc71c92', Digest::SipHash24.hexdigest('siphash', key: key)
        assert_equal '064ced3bea4abf32', Digest::SipHash24.hexdigest('digest-sip_hash', key: key)
        assert_equal '3d1ce6276d329229', Digest::SipHash24.hexdigest('x' * 1_000, key: key)
        assert_equal 'd0da1f6b4e838b97', Digest::SipHash24.hexdigest('abc' * 10_000, key: key)
        assert_equal 'dae7cd2313f56d73', Digest::SipHash24.hexdigest('bulldozer', key: key)
        assert_equal 'd1ce681ecf6810e4', Digest::SipHash24.hexdigest('ishmael', key: key)
        assert_equal '383e7b1932947fd0', Digest::SipHash24.hexdigest('latour', key: key)
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
