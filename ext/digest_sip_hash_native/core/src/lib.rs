#![no_std]

/// `SipHash` constants derived from ASCII strings
const V0: u64 = u64::from_be_bytes(*b"somepseu");
const V1: u64 = u64::from_be_bytes(*b"dorandom");
const V2: u64 = u64::from_be_bytes(*b"lygenera");
const V3: u64 = u64::from_be_bytes(*b"tedbytes");

/// `SipHasher` with configurable compression and finalization rounds
pub struct SipHasher {
    v0: u64,
    v1: u64,
    v2: u64,
    v3: u64,
    comp_rounds: u8,
    fin_rounds: u8,
}

impl SipHasher {
    #[must_use]
    pub const fn new(comp_rounds: u8, fin_rounds: u8, key: &[u8; 16]) -> Self {
        let k0 = u64::from_le_bytes([
            key[0], key[1], key[2], key[3], key[4], key[5], key[6], key[7],
        ]);
        let k1 = u64::from_le_bytes([
            key[8], key[9], key[10], key[11], key[12], key[13], key[14], key[15],
        ]);

        Self {
            v0: V0 ^ k0,
            v1: V1 ^ k1,
            v2: V2 ^ k0,
            v3: V3 ^ k1,
            comp_rounds,
            fin_rounds,
        }
    }

    pub fn hash(&mut self, message: &[u8]) -> [u8; 8] {
        self.transform(message);
        self.finalize()
    }

    fn transform(&mut self, message: &[u8]) {
        let mut chunks = message.chunks_exact(8);

        // Process full 8-byte blocks using chunks_exact iterator
        for chunk in &mut chunks {
            let value = u64::from_le_bytes(
                chunk
                    .try_into()
                    .expect("`chunks_exact` guarantees 8-byte chunks"),
            );
            self.compress_block(value);
        }

        // Process the last incomplete block with remainder bytes
        let last_block = Self::build_last_block(message.len(), chunks.remainder());
        self.compress_block(last_block);
    }

    /// Build the last block with remainder bytes and length encoding
    fn build_last_block(size: usize, remainder: &[u8]) -> u64 {
        let mut last_block = (size as u64) << 56;

        for (index, &byte) in remainder.iter().enumerate() {
            last_block |= u64::from(byte) << (8 * index);
        }

        last_block
    }

    /// Compress a single message block
    #[inline]
    fn compress_block(&mut self, value: u64) {
        self.v3 ^= value;
        for _ in 0..self.comp_rounds {
            self.compress();
        }
        self.v0 ^= value;
    }

    /// Core `SipRound` compression function
    ///
    /// Follows the exact `SipHash` specification (ARX network).
    #[inline]
    const fn compress(&mut self) {
        self.v0 = self.v0.wrapping_add(self.v1);
        self.v1 = self.v1.rotate_left(13);
        self.v1 ^= self.v0;
        self.v0 = self.v0.rotate_left(32);

        self.v2 = self.v2.wrapping_add(self.v3);
        self.v3 = self.v3.rotate_left(16);
        self.v3 ^= self.v2;

        self.v0 = self.v0.wrapping_add(self.v3);
        self.v3 = self.v3.rotate_left(21);
        self.v3 ^= self.v0;

        self.v2 = self.v2.wrapping_add(self.v1);
        self.v1 = self.v1.rotate_left(17);
        self.v1 ^= self.v2;
        self.v2 = self.v2.rotate_left(32);
    }

    /// Finalize and produce the 8-byte digest (big-endian output)
    fn finalize(&mut self) -> [u8; 8] {
        self.v2 ^= 0xff;

        for _ in 0..self.fin_rounds {
            self.compress();
        }

        let hash = self.v0 ^ self.v1 ^ self.v2 ^ self.v3;
        hash.to_be_bytes()
    }
}

/// Convenience function for `SipHash-1-3`
#[must_use]
pub fn siphash13(message: &[u8], key: &[u8; 16]) -> [u8; 8] {
    let mut hasher = SipHasher::new(1, 3, key);
    hasher.hash(message)
}

/// Convenience function for `SipHash-2-4`
#[must_use]
pub fn siphash24(message: &[u8], key: &[u8; 16]) -> [u8; 8] {
    let mut hasher = SipHasher::new(2, 4, key);
    hasher.hash(message)
}
