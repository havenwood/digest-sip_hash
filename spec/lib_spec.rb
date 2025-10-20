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
        assert_equal 'abac0158050fc4dc', Digest::SipHash13.hexdigest('', key:)
        assert_equal 'd5518fe19f28c745', Digest::SipHash13.hexdigest('siphash', key:)
        assert_equal '71783f159400d4b5', Digest::SipHash13.hexdigest('digest-sip_hash', key:)
        assert_equal '2a82bb3e74675b16', Digest::SipHash13.hexdigest('x' * 1_000, key:)
        assert_equal '13152caa40a6671a', Digest::SipHash13.hexdigest('abc' * 10_000, key:)
        assert_equal '503567849e7ff802', Digest::SipHash13.hexdigest('bulldozer', key:)
        assert_equal '39b0f77e620b9655', Digest::SipHash13.hexdigest('ishmael', key:)
        assert_equal '6aafa6fdaf07577a', Digest::SipHash13.hexdigest('latour', key:)
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
        assert_equal '726fdb47dd0e0e31', Digest::SipHash24.hexdigest('', key:)
        assert_equal '882768570dc71c92', Digest::SipHash24.hexdigest('siphash', key:)
        assert_equal '064ced3bea4abf32', Digest::SipHash24.hexdigest('digest-sip_hash', key:)
        assert_equal '3d1ce6276d329229', Digest::SipHash24.hexdigest('x' * 1_000, key:)
        assert_equal 'd0da1f6b4e838b97', Digest::SipHash24.hexdigest('abc' * 10_000, key:)
        assert_equal 'dae7cd2313f56d73', Digest::SipHash24.hexdigest('bulldozer', key:)
        assert_equal 'd1ce681ecf6810e4', Digest::SipHash24.hexdigest('ishmael', key:)
        assert_equal '383e7b1932947fd0', Digest::SipHash24.hexdigest('latour', key:)
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

  describe '.digest (binary output)' do
    it 'returns binary digest instead of hex' do
      hex = Digest::SipHash13.hexdigest('')
      binary = Digest::SipHash13.digest('')
      assert_equal hex, binary.unpack1('H*')
      assert_equal 8, binary.bytesize
      assert_equal Encoding::BINARY, binary.encoding
    end

    it 'works for SipHash24' do
      hex = Digest::SipHash24.hexdigest('siphash')
      binary = Digest::SipHash24.digest('siphash')
      assert_equal hex, binary.unpack1('H*')
    end

    it 'works with custom key' do
      key = 16.times.map(&:chr).join
      hex = Digest::SipHash13.hexdigest('test', key:)
      binary = Digest::SipHash13.digest('test', key:)
      assert_equal hex, binary.unpack1('H*')
    end
  end

  describe 'instance API' do
    it 'works with << for incremental updates' do
      hasher = Digest::SipHash13.new
      hasher << 'sip'
      hasher << 'hash'
      assert_equal Digest::SipHash13.hexdigest('siphash'), hasher.hexdigest
    end

    it 'works with update alias' do
      hasher = Digest::SipHash13.new
      hasher.update('sip')
      hasher.update('hash')
      assert_equal Digest::SipHash13.hexdigest('siphash'), hasher.hexdigest
    end

    it 'supports reset' do
      hasher = Digest::SipHash13.new
      hasher << 'wrong'
      hasher.reset
      hasher << 'siphash'
      assert_equal Digest::SipHash13.hexdigest('siphash'), hasher.hexdigest
    end

    it 'supports multiple digests with reset' do
      hasher = Digest::SipHash13.new
      hasher << 'first'
      first = hasher.hexdigest
      hasher.reset
      hasher << 'second'
      second = hasher.hexdigest

      assert_equal Digest::SipHash13.hexdigest('first'), first
      assert_equal Digest::SipHash13.hexdigest('second'), second
      refute_equal first, second
    end

    it 'returns self from << for chaining' do
      hasher = Digest::SipHash13.new
      result = hasher << 'test'
      assert_same hasher, result
    end

    it 'works with custom rounds' do
      hasher = Digest::SipHash.new(3, 5)
      hasher << 'test'
      assert_equal Digest::SipHash.new(3, 5).hexdigest('test'), hasher.hexdigest
    end

    it 'works with custom key' do
      key = 16.times.map(&:chr).join
      hasher = Digest::SipHash13.new(key:)
      hasher << 'test'
      assert_equal Digest::SipHash13.hexdigest('test', key:), hasher.hexdigest
    end
  end

  describe 'edge cases' do
    describe 'message sizes around 8-byte boundaries' do
      it 'handles 7-byte messages' do
        assert_equal 'a33d651594fdae81', Digest::SipHash13.hexdigest('1234567')
      end

      it 'handles 8-byte messages' do
        assert_equal '3489982430560a87', Digest::SipHash13.hexdigest('12345678')
      end

      it 'handles 9-byte messages' do
        assert_equal '0fbc0f0007965fcf', Digest::SipHash13.hexdigest('123456789')
      end

      it 'handles 15-byte messages' do
        assert_equal '6373230ea5f97ef2', Digest::SipHash13.hexdigest('1' * 15)
      end

      it 'handles 16-byte messages' do
        assert_equal '62441099c0a470b9', Digest::SipHash13.hexdigest('1' * 16)
      end

      it 'handles 17-byte messages' do
        assert_equal '4a515ba1033eb057', Digest::SipHash13.hexdigest('1' * 17)
      end
    end

    describe 'binary data' do
      it 'handles null bytes' do
        message = "\x00\x00\x00\x00"
        assert_equal 'cc2247b79ac48af0', Digest::SipHash13.hexdigest(message)
      end

      it 'handles binary sequences' do
        message = (0..255).map(&:chr).join
        assert_equal '31ae646afba70308', Digest::SipHash13.hexdigest(message)
      end

      it 'handles high-bit bytes' do
        message = "\xFF\xFE\xFD\xFC"
        assert_equal '2ae5806b4db01fd6', Digest::SipHash13.hexdigest(message)
      end
    end

    describe 'incremental vs single update' do
      it 'produces same result for split updates' do
        single = Digest::SipHash13.new
        single << 'abcdefghijklmnop'

        incremental = Digest::SipHash13.new
        incremental << 'abcd'
        incremental << 'efgh'
        incremental << 'ijkl'
        incremental << 'mnop'

        assert_equal single.hexdigest, incremental.hexdigest
      end

      it 'handles boundary-crossing splits' do
        single = Digest::SipHash13.new
        single << '12345678901234567'

        incremental = Digest::SipHash13.new
        incremental << '1234567'
        incremental << '8'
        incremental << '90123456'
        incremental << '7'

        assert_equal single.hexdigest, incremental.hexdigest
      end
    end
  end

  describe 'constants' do
    it 'has DEFAULT_KEY constant' do
      assert_equal 16, Digest::SipHash::DEFAULT_KEY.bytesize
      assert_equal "\x00" * 16, Digest::SipHash::DEFAULT_KEY
    end

    it 'uses DEFAULT_KEY when no key provided' do
      with_default = Digest::SipHash13.hexdigest('test')
      with_explicit = Digest::SipHash13.hexdigest('test', key: Digest::SipHash::DEFAULT_KEY)
      assert_equal with_default, with_explicit
    end
  end
end
