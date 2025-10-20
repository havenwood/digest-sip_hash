# Digest::SipHash

A Ruby implementation of SipHash with optional Rust native extension. Supports SipHash 1-3, 2-4 or arbitrary round counts. Defaults to SipHash 1-3 with 16 null bytes as the key.

## What is SipHash?

[SipHash](https://github.com/veorq/SipHash) is a fast, cryptographically strong pseudorandom function optimized for short inputs.

## Requirements

- Ruby 3.0+
- Optional: Rust 2024+ edition (automatic native extension compilation)

## Installation

```bash
gem install digest-sip_hash
```

## Quick Start

```ruby
require 'digest/sip_hash'
require 'securerandom'

# Basic usage with default settings (SipHash 1-3)
Digest::SipHash.hexdigest('hello world')
#=> "421ga35b9c80c1c4"

# Use a secret key for authentication
secret = SecureRandom.random_bytes(16)
Digest::SipHash.new(key: secret).hexdigest('message')
#=> "a4d2f8b6e3c91d7f"

# SipHash 2-4 variant
Digest::SipHash24.hexdigest('hello world')
#=> "5ee588584e5b2333"
```

## Performance

When Rust is available the native extension builds automatically and dramatically improves runtime performance. On my machine the native extension is:
- More than **10x faster** with an 8 byte messages
- More than **1,000x faster** with a 4,096 byte messages

## Examples

### Standard Variants

```ruby
# SipHash 1-3 (default: 1 compression round, 3 finalization rounds)
Digest::SipHash.hexdigest('')
#=> "d1fba762150c532c"

Digest::SipHash13.hexdigest('')
#=> "d1fba762150c532c"

# SipHash 2-4 (original specification)
Digest::SipHash24.hexdigest('')
#=> "1e924b9d737700d7"

Digest::SipHash.new(2, 4).hexdigest('')
#=> "1e924b9d737700d7"
```

### Custom Round Counts

```ruby
# Higher security with more rounds
Digest::SipHash.new(4, 8).hexdigest('')
#=> "23ec6dd806738af3"

Digest::SipHash.new(8, 16).hexdigest('')
#=> "c05e9233091eb559"
```

### Using Custom Keys

```ruby
require 'digest/sip_hash'
require 'securerandom'

# Default key (16 null bytes)
Digest::SipHash.new(key: 0.chr * 16).hexdigest('')
#=> "d1fba762150c532c"

# Custom key
Digest::SipHash.new(key: 16.times.map(&:chr).join).hexdigest('')
#=> "abac0158050fc4dc"

# Secure random key
secret = SecureRandom.random_bytes(16)
digest = Digest::SipHash.new(key: secret)
digest.hexdigest('message')
#=> "dd854240c470edef"
```

### Incremental Hashing

```ruby
digest = Digest::SipHash.new
digest << 'hello'
digest << ' '
digest << 'world'
digest.hexdigest
#=> "421ga35b9c80c1c4"
```

## Command Line Examples

```
Usage: siphash [OPTIONS] FILE
    -c=ROUNDS                        Number of c rounds. Default: 1
    -d=ROUNDS                        Number of d rounds. Default: 3
    -k, --key=KEY                    Sixteen-byte hex key. Default: "00000000000000000000000000000000"
```

Check hashes by providing a filename to the `siphash` executable:
```sh
touch empty_file
siphash empty_file
#>> d1fba762150c532c  empty_file
```

Or pipe input to `siphash`:
```sh
# SipHash 1-3
echo -n "" | siphash
#>> d1fba762150c532c  -

# SipHash 2-4
echo -n "" | siphash -c2 -d4
#>> 1e924b9d737700d7  -

echo -n "" | siphash --key "00010203040506070809101112131415"
#>> 067c02f6c87ccd93  -
```

## Alternatives

- Pure C extension: [digest-siphash](https://github.com/ksss/digest-siphash)

## License

MIT
