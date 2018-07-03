# Digest::SipHash

A pure Ruby implementation of SipHash 1-3 and 2-4. Arbitrary round counts are also supported. If rounds and key are not specified, the default is SipHash 1-3 with a key of 16 null bytes.

## Installation

```bash
gem install digest-sip_hash
```

## Library Examples

The default key is 16 null bytes.

```ruby
require 'digest/sip_hash'

Digest::SipHash.hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash13.hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash.new(1, 3).hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash.new(key: 0.chr * 16).hexdigest ''
#=> "d1fba762150c532c"

Digest::SipHash.new(key: 16.times.map(&:chr).join).hexdigest ''
#=> "abac0158050fc4dc"

Digest::SipHash.new(2, 4).hexdigest ''
#=> "1e924b9d737700d7"

Digest::SipHash24.hexdigest ''
#=> "1e924b9d737700d7"

Digest::SipHash.new(4, 8).hexdigest ''
#=> "23ec6dd806738af3"

Digest::SipHash.new(8, 16).hexdigest ''
#=> "c05e9233091eb559"
```

Use `SecureRandom.bytes 16` to generate a random key.

```ruby
require 'digest/sip_hash'
require 'securerandom'

secret = SecureRandom.bytes 16
#=> "\r\xCBv\xE7\xA2V\xB9X`NP4[0\x98\xFD"

digest = Digest::SipHash.new
#=> #<Digest::SipHash: d1fba762150c532c>

digest.hexdigest
#=> "d1fba762150c532c"

digest.key = secret
#=> "\r\xCBv\xE7\xA2V\xB9X`NP4[0\x98\xFD"

digest.hexdigest
#=> "dd854240c470edef"

digest << 'nom'
#<Digest::SipHash: 85b61bc79bb9e7c4>

digest.hexdigest
#=> "85b61bc79bb9e7c4"
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

## C-Extension Alternative

[digest-siphash](https://github.com/ksss/digest-siphash)

## Requirements

Ruby 2.5+

## License

MIT
