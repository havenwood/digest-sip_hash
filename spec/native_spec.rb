# frozen_string_literal: true

require_relative 'helper'

describe 'Native Extension' do
  if Digest::SipHash.native?
    it 'actually uses native implementation' do
      hasher = Digest::SipHash13.new
      hasher << 'test'
      result = hasher.hexdigest

      assert hasher.native?, 'Should use native finish, not Ruby fallback'
      assert_equal 'e0969da9b8fb378d', result
    end

    it 'produces correct results for various inputs' do
      test_cases = [
        ['', 'd1fba762150c532c'],
        ['test', 'e0969da9b8fb378d'],
        ['siphash', '8264ceeccb16bcbe'],
        ['x' * 1000, '1b47c0cc4dd21f05']
      ]

      test_cases.each do |input, expected|
        hasher = Digest::SipHash13.new
        result = hasher.hexdigest(input)

        assert hasher.native?, "Should use native for: #{input.inspect}"
        assert_equal expected, result, "Failed for input: #{input.inspect}"
      end
    end

    it 'correctly passes custom rounds from Ruby to Rust' do
      hasher = Digest::SipHash.new(1, 2)
      result = hasher.hexdigest('')

      assert hasher.native?, 'Should use native for custom rounds'
      assert_equal '3204eeb59b3cccdd', result

      hasher = Digest::SipHash.new(3, 5)
      result = hasher.hexdigest('')

      assert hasher.native?, 'Should use native for custom rounds'
      assert_equal '95772adebda3f3f0', result
    end

    it 'correctly passes custom key from Ruby to Rust' do
      key = 16.times.map(&:chr).join

      hasher = Digest::SipHash13.new(key:)
      result = hasher.hexdigest('')

      assert hasher.native?, 'Should use native for custom key'
      assert_equal 'abac0158050fc4dc', result

      hasher = Digest::SipHash13.new(key:)
      result = hasher.hexdigest('siphash')

      assert hasher.native?, 'Should use native for custom key'
      assert_equal 'd5518fe19f28c745', result
    end

    it 'handles binary data correctly' do
      binary = "\xFF\xFE\xFD\xFC"
      hasher = Digest::SipHash13.new
      result = hasher.hexdigest(binary)

      assert hasher.native?, 'Should use native for binary data'
      assert_equal '2ae5806b4db01fd6', result
    end
  else
    it 'skips native tests when extension not loaded' do
      skip 'Native extension not available'
    end
  end
end
