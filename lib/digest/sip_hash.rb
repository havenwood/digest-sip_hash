# frozen_string_literal: true

require 'digest'
require 'digest/sip_hash/version'

module Digest
  # SipHash cryptographic hash function implementation
  class SipHash < Digest::Class
    DEFAULT_KEY = 0.chr * 16

    attr_accessor :key

    def initialize(comp_rounds = 1, fin_rounds = 3, key: DEFAULT_KEY)
      super()
      @comp_rounds = comp_rounds
      @fin_rounds = fin_rounds
      @key = key
      @buffer = String.new(encoding: Encoding::BINARY, capacity: 64)
      @native = true
    end

    def <<(input)
      @buffer << input
      self
    end
    alias update <<

    def reset
      @buffer.clear
      @native = true
      self
    end

    def finish
      @native = false
      hasher = SipHasher.new(@buffer, @comp_rounds, @fin_rounds, @key)
      hasher.transform
      hasher.finalize
    end

    def native?
      @native == true
    end

    # SipHash algorithm
    class SipHasher
      MASK = 2**64 - 1
      V0 = 'somepseu'.unpack1('Q>')
      V1 = 'dorandom'.unpack1('Q>')
      V2 = 'lygenera'.unpack1('Q>')
      V3 = 'tedbytes'.unpack1('Q>')

      def initialize(message, comp_rounds, fin_rounds, key)
        @message = message
        @comp_rounds = comp_rounds
        @fin_rounds = fin_rounds

        k0 = key[0..7].unpack1('Q<')
        k1 = key[8..15].unpack1('Q<')

        @v0 = V0 ^ k0
        @v1 = V1 ^ k1
        @v2 = V2 ^ k0
        @v3 = V3 ^ k1
      end

      def transform
        (@message.size / 8).times { |index| compress_block block index }
        compress_block last_block
      end

      def finalize
        @v2 ^= 0xff
        @fin_rounds.times { compress }
        [@v0 ^ @v1 ^ @v2 ^ @v3].pack('Q>')
      end

      private

      def compress_block(value)
        @v3 ^= value
        @comp_rounds.times { compress }
        @v0 ^= value
      end

      def block(index) = @message.slice(index * 8, 8).unpack1('Q<')

      def last_block
        size = @message.size
        remainder = size % 8
        offset = size - remainder

        remainder.times.reduce size << 56 & MASK do |last_block, index|
          last_block | @message.getbyte(index + offset) << 8 * index
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

      def add(left, right) = left + right & MASK

      def rotate(value, bits, xor = 0)
        value << bits & MASK | value >> 64 - bits ^ xor
      end
    end
  end

  # SipHash-1-3: Common faster variant
  class SipHash13 < SipHash
    def initialize(key: DEFAULT_KEY) = super(1, 3, key:)

    def self.hexdigest(str, key: DEFAULT_KEY) = new(key:).hexdigest(str)
    def self.digest(str, key: DEFAULT_KEY) = new(key:).digest(str)
  end

  # SipHash-2-4: Common more secure variant
  class SipHash24 < SipHash
    def initialize(key: DEFAULT_KEY) = super(2, 4, key:)

    def self.hexdigest(str, key: DEFAULT_KEY) = new(key:).hexdigest(str)
    def self.digest(str, key: DEFAULT_KEY) = new(key:).digest(str)
  end
end

# Load native extension after Ruby so Rust can override the `finish` method
begin
  require 'digest/sip_hash/digest_sip_hash_native'

  module Digest
    class SipHash
      def self.native? = true
    end
  end
rescue LoadError
  module Digest
    class SipHash
      def self.native? = false
    end
  end
end
