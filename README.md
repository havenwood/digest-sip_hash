# Digest::SipHash

A pure Ruby implementation of SipHash 1-3 and 2-4. Arbitrary round counts are also supported. If rounds and key are not specified, the default is SipHash 1-3 with a key of sixteen null bytes.

## Installation

```bash
gem install digest-sip_hash
```

## Library Examples

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
