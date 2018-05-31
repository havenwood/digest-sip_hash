# Digest::SipHash

A pure Ruby implementation of SipHash 1-3 and 2-4.

## Installation

```bash
gem install digest-sip_hash
```

## Usage Examples

The default key is 16 null bytes. Use `SecureRandom.bytes 16` to generate a random key.

```ruby
Digest::SipHash.new.hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash.new(key: 16.times.map(&:chr).join).hexdigest ''
#=> "abac0158050fc4dc"

Digest::SipHash.new(1, 3).hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash13.hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash.new(2, 4).hexdigest ''
#=> "1e924b9d737700d7"

Digest::SipHash24.hexdigest ''
#=> "1e924b9d737700d7"
```

## C-Extension Alternative

[digest-siphash](https://github.com/ksss/digest-siphash)

## Requirements

Ruby 2.5+

## License

MIT
