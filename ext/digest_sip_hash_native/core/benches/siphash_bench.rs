use criterion::{BenchmarkId, Criterion, Throughput, black_box, criterion_group, criterion_main};
use digest_sip_hash_core::{SipHasher, siphash13, siphash24};

const DEFAULT_KEY: [u8; 16] = [0; 16];

fn bench_siphash13(c: &mut Criterion) {
    let mut group = c.benchmark_group("siphash13");

    // Small message (empty)
    group.throughput(Throughput::Bytes(0));
    group.bench_function("empty", |b| {
        b.iter(|| siphash13(black_box(b""), black_box(&DEFAULT_KEY)));
    });

    // Small message
    group.throughput(Throughput::Bytes(7));
    group.bench_function("7 bytes", |b| {
        b.iter(|| siphash13(black_box(b"siphash"), black_box(&DEFAULT_KEY)));
    });

    // Medium message
    group.throughput(Throughput::Bytes(15));
    group.bench_function("15 bytes", |b| {
        b.iter(|| siphash13(black_box(b"digest-sip_hash"), black_box(&DEFAULT_KEY)));
    });

    // Larger messages
    for size in &[64, 256, 1024, 4096] {
        let data = vec![b'x'; *size];
        group.throughput(Throughput::Bytes(*size as u64));
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{size} bytes")),
            size,
            |b, _| {
                b.iter(|| siphash13(black_box(&data), black_box(&DEFAULT_KEY)));
            },
        );
    }

    group.finish();
}

fn bench_siphash24(c: &mut Criterion) {
    let mut group = c.benchmark_group("siphash24");

    // Small message
    group.throughput(Throughput::Bytes(7));
    group.bench_function("7 bytes", |b| {
        b.iter(|| siphash24(black_box(b"siphash"), black_box(&DEFAULT_KEY)));
    });

    // Larger messages
    for size in &[64, 256, 1024, 4096] {
        let data = vec![b'x'; *size];
        group.throughput(Throughput::Bytes(*size as u64));
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{size} bytes")),
            size,
            |b, _| {
                b.iter(|| siphash24(black_box(&data), black_box(&DEFAULT_KEY)));
            },
        );
    }

    group.finish();
}

fn bench_compress_rounds(c: &mut Criterion) {
    let mut group = c.benchmark_group("compress_function");

    let message = b"digest-sip_hash";

    for rounds in &[1, 2, 4, 8] {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{rounds} c-rounds")),
            rounds,
            |b, &rounds| {
                let mut hasher = SipHasher::new(rounds, 3, &DEFAULT_KEY);
                b.iter(|| hasher.hash(black_box(message)));
            },
        );
    }

    group.finish();
}

criterion_group!(
    benches,
    bench_siphash13,
    bench_siphash24,
    bench_compress_rounds
);
criterion_main!(benches);
