# frozen_string_literal: true

require 'digest'
require 'digest/sip_hash/version'

module Digest
  class SipHash < Digest::Class
    DEFAULT_KEY = 0.chr * 16

    attr_accessor :key

    def initialize c_rounds = 1, d_rounds = 3, key: DEFAULT_KEY
      @c_rounds = c_rounds
      @d_rounds = d_rounds
      @key = key
      @buffer = +''
    end

    def << s
      @buffer << s
      self
    end
    alias update <<

    def reset
      @buffer.clear
      self
    end

    def finish
      sip = Sip.new @buffer, @key, @c_rounds, @d_rounds
      sip.transform
      sip.finalize
    end

    class Sip
      MASK = 2 ** 64 - 1
      V0 = 'somepseu'.unpack1 'Q>'
      V1 = 'dorandom'.unpack1 'Q>'
      V2 = 'lygenera'.unpack1 'Q>'
      V3 = 'tedbytes'.unpack1 'Q>'

      def initialize buffer, key, c_rounds, d_rounds
        @buffer = buffer
        @size = @buffer.size
        @c_rounds = c_rounds
        @d_rounds = d_rounds

        k0 = key[0..7].unpack1 'Q<'
        k1 = key[8..15].unpack1 'Q<'

        @v0 = V0 ^ k0
        @v1 = V1 ^ k1
        @v2 = V2 ^ k0
        @v3 = V3 ^ k1
      end

      def transform
        return compress_word 0 if @size.zero?
        (@size / 8).times { |n| compress_word word n }
        compress_word last_word
      end

      def finalize
        @v2 ^= 2 ** 8 - 1
        @d_rounds.times { compress }
        [@v0 ^ @v1 ^ @v2 ^ @v3].pack 'Q>'
      end

      private

      def compress_word m
        @v3 ^= m
        @c_rounds.times { compress }
        @v0 ^= m
      end

      def word n
        @buffer.slice(n * 8, 8).unpack1 'Q<'
      end

      def last_word
        remainder = @size % 8
        offset = @size - remainder

        [remainder, 8].min.pred.downto(0).reduce(@size << 56 & MASK) do |acc, n|
          acc | @buffer[n + offset].ord << 8 * n
        end
      end

      def compress
        @v0 = add @v0, @v1
        @v1 = rotate @v1, 13, @v0
        @v0 = rotate @v0, 32
        @v2 = add @v2, @v3
        @v3 = rotate @v3, 16, @v2
        @v0 = add @v0, @v3
        @v3 = rotate @v3, 21, @v0
        @v2 = add @v2, @v1
        @v1 = rotate @v1, 17, @v2
        @v2 = rotate @v2, 32
      end

      def add a, b
        a + b & MASK
      end

      def rotate n, by, xor = 0
        (n << by & MASK | n >> 64 - by) ^ xor
      end
    end
  end

  class SipHash13 < SipHash
    def initialize key: DEFAULT_KEY
      super 1, 3, key: key
    end
  end

  class SipHash24 < SipHash
    def initialize key: DEFAULT_KEY
      super 2, 4, key: key
    end
  end
end
