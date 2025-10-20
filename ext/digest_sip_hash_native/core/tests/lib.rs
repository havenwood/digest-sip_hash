use digest_sip_hash_core::{SipHasher, siphash13, siphash24};

const DEFAULT_KEY: [u8; 16] = [0; 16];

fn to_hex(bytes: &[u8]) -> String {
    use std::fmt::Write;
    let mut hex = String::with_capacity(bytes.len() * 2);
    for byte in bytes {
        write!(hex, "{byte:02x}").expect("write to String should never fail in test helper");
    }
    hex
}

#[test]
fn test_siphash13_default_key() {
    assert_eq!(to_hex(&siphash13(b"", &DEFAULT_KEY)), "d1fba762150c532c");
    assert_eq!(
        to_hex(&siphash13(b"siphash", &DEFAULT_KEY)),
        "8264ceeccb16bcbe"
    );
    assert_eq!(
        to_hex(&siphash13(b"digest-sip_hash", &DEFAULT_KEY)),
        "ce31007e34130c0a"
    );
    assert_eq!(
        to_hex(&siphash13(b"bulldozer", &DEFAULT_KEY)),
        "8421ff50252ef54c"
    );
    assert_eq!(
        to_hex(&siphash13(b"ishmael", &DEFAULT_KEY)),
        "1ad2b299abf672fd"
    );
    assert_eq!(
        to_hex(&siphash13(b"latour", &DEFAULT_KEY)),
        "1403853b32c9a3d7"
    );
}

#[test]
fn test_siphash13_custom_key() {
    let key: [u8; 16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    assert_eq!(to_hex(&siphash13(b"", &key)), "abac0158050fc4dc");
    assert_eq!(to_hex(&siphash13(b"siphash", &key)), "d5518fe19f28c745");
    assert_eq!(
        to_hex(&siphash13(b"digest-sip_hash", &key)),
        "71783f159400d4b5"
    );
    assert_eq!(to_hex(&siphash13(b"bulldozer", &key)), "503567849e7ff802");
    assert_eq!(to_hex(&siphash13(b"ishmael", &key)), "39b0f77e620b9655");
    assert_eq!(to_hex(&siphash13(b"latour", &key)), "6aafa6fdaf07577a");
}

#[test]
fn test_siphash24_default_key() {
    assert_eq!(to_hex(&siphash24(b"", &DEFAULT_KEY)), "1e924b9d737700d7");
    assert_eq!(
        to_hex(&siphash24(b"siphash", &DEFAULT_KEY)),
        "59caaeb90d542464"
    );
    assert_eq!(
        to_hex(&siphash24(b"digest-sip_hash", &DEFAULT_KEY)),
        "4b5cd6bb2500bc8f"
    );
    assert_eq!(
        to_hex(&siphash24(b"bulldozer", &DEFAULT_KEY)),
        "35e35e884f56688f"
    );
    assert_eq!(
        to_hex(&siphash24(b"ishmael", &DEFAULT_KEY)),
        "98585807dafda42b"
    );
    assert_eq!(
        to_hex(&siphash24(b"latour", &DEFAULT_KEY)),
        "3802759a0e659a96"
    );
}

#[test]
fn test_siphash24_custom_key() {
    let key: [u8; 16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    assert_eq!(to_hex(&siphash24(b"", &key)), "726fdb47dd0e0e31");
    assert_eq!(to_hex(&siphash24(b"siphash", &key)), "882768570dc71c92");
    assert_eq!(
        to_hex(&siphash24(b"digest-sip_hash", &key)),
        "064ced3bea4abf32"
    );
    assert_eq!(to_hex(&siphash24(b"bulldozer", &key)), "dae7cd2313f56d73");
    assert_eq!(to_hex(&siphash24(b"ishmael", &key)), "d1ce681ecf6810e4");
    assert_eq!(to_hex(&siphash24(b"latour", &key)), "383e7b1932947fd0");
}

#[test]
fn test_arbitrary_rounds() {
    let mut hasher = SipHasher::new(1, 2, &DEFAULT_KEY);
    assert_eq!(to_hex(&hasher.hash(b"")), "3204eeb59b3cccdd");

    let key: [u8; 16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    let mut hasher = SipHasher::new(1, 2, &key);
    assert_eq!(to_hex(&hasher.hash(b"")), "cea28b51565c12e2");

    let mut hasher = SipHasher::new(3, 5, &DEFAULT_KEY);
    assert_eq!(to_hex(&hasher.hash(b"")), "95772adebda3f3f0");
}

#[test]
fn test_large_messages() {
    // Test with 1000 'x' characters
    let msg1000 = vec![b'x'; 1000];
    assert_eq!(
        to_hex(&siphash13(&msg1000, &DEFAULT_KEY)),
        "1b47c0cc4dd21f05"
    );
    assert_eq!(
        to_hex(&siphash24(&msg1000, &DEFAULT_KEY)),
        "a07a230346e2656b"
    );

    // Test with 30000 'abc' repeats (90000 bytes)
    let mut msg30k = Vec::new();
    for _ in 0..10_000 {
        msg30k.extend_from_slice(b"abc");
    }
    assert_eq!(
        to_hex(&siphash13(&msg30k, &DEFAULT_KEY)),
        "136ea6cf74ee7506"
    );
    assert_eq!(
        to_hex(&siphash24(&msg30k, &DEFAULT_KEY)),
        "2e05ad971738666e"
    );

    // Test with custom key
    let key: [u8; 16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    assert_eq!(to_hex(&siphash13(&msg1000, &key)), "2a82bb3e74675b16");
    assert_eq!(to_hex(&siphash13(&msg30k, &key)), "13152caa40a6671a");
    assert_eq!(to_hex(&siphash24(&msg1000, &key)), "3d1ce6276d329229");
    assert_eq!(to_hex(&siphash24(&msg30k, &key)), "d0da1f6b4e838b97");
}

#[test]
fn test_arbitrary_rounds_large_messages() {
    let msg1000 = vec![b'x'; 1000];
    let mut hasher = SipHasher::new(3, 5, &DEFAULT_KEY);
    assert_eq!(to_hex(&hasher.hash(&msg1000)), "f344baf915afc13a");
}

#[test]
fn test_message_sizes_around_boundaries() {
    // 7-byte message (one byte short of block)
    assert_eq!(
        to_hex(&siphash13(b"1234567", &DEFAULT_KEY)),
        "a33d651594fdae81"
    );

    // 8-byte message (exactly one block)
    assert_eq!(
        to_hex(&siphash13(b"12345678", &DEFAULT_KEY)),
        "3489982430560a87"
    );

    // 9-byte message (one byte over block)
    assert_eq!(
        to_hex(&siphash13(b"123456789", &DEFAULT_KEY)),
        "0fbc0f0007965fcf"
    );

    // 15-byte message (one byte short of two blocks)
    let msg15 = b"111111111111111";
    assert_eq!(to_hex(&siphash13(msg15, &DEFAULT_KEY)), "6373230ea5f97ef2");

    // 16-byte message (exactly two blocks)
    let msg16 = b"1111111111111111";
    assert_eq!(to_hex(&siphash13(msg16, &DEFAULT_KEY)), "62441099c0a470b9");

    // 17-byte message (one byte over two blocks)
    let msg17 = b"11111111111111111";
    assert_eq!(to_hex(&siphash13(msg17, &DEFAULT_KEY)), "4a515ba1033eb057");
}

#[test]
fn test_binary_data() {
    // Null bytes
    let null_bytes = b"\x00\x00\x00\x00";
    assert_eq!(
        to_hex(&siphash13(null_bytes, &DEFAULT_KEY)),
        "cc2247b79ac48af0"
    );

    // Binary sequence 0-255
    let binary_seq: Vec<u8> = (0..=255).collect();
    assert_eq!(
        to_hex(&siphash13(&binary_seq, &DEFAULT_KEY)),
        "31ae646afba70308"
    );

    // High-bit bytes
    let high_bits = b"\xFF\xFE\xFD\xFC";
    assert_eq!(
        to_hex(&siphash13(high_bits, &DEFAULT_KEY)),
        "2ae5806b4db01fd6"
    );
}
