#![allow(unsafe_code, reason = "FFI requires unsafe for Ruby interop")]

use digest_sip_hash_core::SipHasher;
use magnus::value::ReprValue;
use magnus::{
    Error, Module, Object, RClass, RModule, RObject, RString, Ruby, TryConvert, Value, method,
};

fn finish_native(ruby: &Ruby, rb_self: Value) -> Result<RString, Error> {
    let obj = RObject::try_convert(rb_self)?;
    let buffer: RString = obj.ivar_get("@buffer")?;
    let comp_rounds_value: Value = obj.ivar_get("@comp_rounds")?;
    if comp_rounds_value.is_nil() {
        return Err(Error::new(
            ruby.exception_runtime_error(),
            "@comp_rounds instance variable is nil or missing",
        ));
    }
    let comp_rounds: i64 = i64::try_convert(comp_rounds_value)?;

    let fin_rounds_value: Value = obj.ivar_get("@fin_rounds")?;
    if fin_rounds_value.is_nil() {
        return Err(Error::new(
            ruby.exception_runtime_error(),
            "@fin_rounds instance variable is nil or missing",
        ));
    }
    let fin_rounds: i64 = i64::try_convert(fin_rounds_value)?;

    let key: RString = obj.ivar_get("@key")?;

    // SAFETY: RString::as_slice provides valid data for the lifetime of the RString
    let message = unsafe { buffer.as_slice() };
    // SAFETY: RString::as_slice provides valid data for the lifetime of the RString
    let key_bytes = unsafe { key.as_slice() };

    if key_bytes.len() != 16 {
        let len = key_bytes.len();
        return Err(Error::new(
            ruby.exception_arg_error(),
            format!("key must be exactly 16 bytes, got {len}"),
        ));
    }

    let key_array: [u8; 16] = key_bytes
        .try_into()
        .map_err(|_| Error::new(ruby.exception_runtime_error(), "failed to convert key"))?;

    let mut hasher = SipHasher::new(comp_rounds as u8, fin_rounds as u8, &key_array);
    let digest = hasher.hash(message);

    Ok(ruby.str_from_slice(&digest))
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let digest_module: RModule = ruby.class_object().const_get("Digest")?;
    let sip_hash_class: RClass = digest_module.const_get("SipHash")?;

    sip_hash_class.define_method("finish", method!(finish_native, 0))?;

    Ok(())
}
