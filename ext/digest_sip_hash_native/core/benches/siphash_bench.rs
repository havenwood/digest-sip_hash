use criterion::{Criterion, Throughput, black_box, criterion_group, criterion_main};
use digest_sip_hash_core::SipHasher;

const DEFAULT_KEY: [u8; 16] = [0; 16];

fn bench_siphash13(c: &mut Criterion) {
    let mut group = c.benchmark_group("siphash13");

    group.throughput(Throughput::Bytes(8));
    group.bench_function("8 bytes", |b| {
        b.iter(|| {
            let mut hasher = SipHasher::new(1, 3, black_box(&DEFAULT_KEY));
            hasher.hash(black_box(b"siphash"))
        });
    });

    let data = vec![b'x'; 4096];
    group.throughput(Throughput::Bytes(4096));
    group.bench_function("4096 bytes", |b| {
        b.iter(|| {
            let mut hasher = SipHasher::new(1, 3, black_box(&DEFAULT_KEY));
            hasher.hash(black_box(&data))
        });
    });

    group.finish();
}

fn bench_siphash24(c: &mut Criterion) {
    let mut group = c.benchmark_group("siphash24");

    group.throughput(Throughput::Bytes(8));
    group.bench_function("8 bytes", |b| {
        b.iter(|| {
            let mut hasher = SipHasher::new(2, 4, black_box(&DEFAULT_KEY));
            hasher.hash(black_box(b"siphash"))
        });
    });

    let data = vec![b'x'; 4096];
    group.throughput(Throughput::Bytes(4096));
    group.bench_function("4096 bytes", |b| {
        b.iter(|| {
            let mut hasher = SipHasher::new(2, 4, black_box(&DEFAULT_KEY));
            hasher.hash(black_box(&data))
        });
    });

    group.finish();
}

criterion_group!(benches, bench_siphash13, bench_siphash24);
criterion_main!(benches);
