# Poseidon2 Implementation for Zig

This module provides a Zig implementation of the Poseidon2 hash function that is fully compatible with Plonky3's KoalaBear field implementation.

## Features

- **Plonky3 Compatible**: Uses the exact same field arithmetic and parameters as Plonky3
- **KoalaBear Field**: Implements the KoalaBear field (2^31 - 2^24 + 1) with normal form arithmetic
- **Poseidon2-16 and Poseidon2-24**: Supports both 16-width and 24-width variants
- **Exact Round Constants**: Uses the same round constants as Plonky3
- **Optimized MDS Matrix**: Implements the exact MDS matrix operations from Plonky3

## Usage

```zig
const poseidon2 = @import("plonky3_poseidon2/root.zig");

// Create field elements
const field_val = poseidon2.Field.fromU32(42);

// Run Poseidon2-16 permutation
var state = [_]poseidon2.Field{undefined} ** 16;
// ... initialize state ...
poseidon2.poseidon2_16(&state);

// Run Poseidon2-24 permutation
var state24 = [_]poseidon2.Field{undefined} ** 24;
// ... initialize state ...
poseidon2.poseidon2_24(&state24);
```

## API Reference

### Field Operations
- `Field.fromU32(x: u32) -> Field`: Convert u32 to field element
- `Field.toU32(self: Field) -> u32`: Convert field element to u32
- `Field.add(self: Field, other: Field) -> Field`: Field addition
- `Field.mul(self: Field, other: Field) -> Field`: Field multiplication
- `Field.inverse(self: Field) -> Field`: Field inverse

### Poseidon2 Functions
- `poseidon2_16(state: []Field) -> void`: Run Poseidon2-16 permutation
- `poseidon2_24(state: []Field) -> void`: Run Poseidon2-24 permutation
- `sbox(x: Field) -> Field`: S-box operation (x^3)
- `apply_mat4(state: []Field, start_idx: usize) -> void`: Apply 4x4 MDS matrix
- `mds_light_permutation_16(state: []Field) -> void`: Apply MDS light permutation for 16-width
- `mds_light_permutation_24(state: []Field) -> void`: Apply MDS light permutation for 24-width

### Round Constants
- `PLONKY3_KOALABEAR_RC16_EXTERNAL_INITIAL`: External initial round constants for 16-width
- `PLONKY3_KOALABEAR_RC16_EXTERNAL_FINAL`: External final round constants for 16-width
- `PLONKY3_KOALABEAR_RC16_INTERNAL`: Internal round constants for 16-width
- `PLONKY3_KOALABEAR_RC24_EXTERNAL_INITIAL`: External initial round constants for 24-width
- `PLONKY3_KOALABEAR_RC24_EXTERNAL_FINAL`: External final round constants for 24-width
- `PLONKY3_KOALABEAR_RC24_INTERNAL`: Internal round constants for 24-width

## Implementation Details

This implementation is based on Plonky3's Poseidon2 implementation and includes:

1. **Field Arithmetic**: Normal form KoalaBear field operations (not Montgomery form)
2. **Round Constants**: Exact round constants from Plonky3's koala-bear crate
3. **MDS Matrix**: Optimized 4x4 MDS matrix operations with outer circulant matrix
4. **Internal Layer**: Exact internal layer operations with partial sum computation
5. **External Layer**: Complete external layer with round constants, S-box, and MDS

## Testing

The implementation has been tested against Plonky3's Poseidon2 implementation to ensure compatibility. All field operations, round constants, and permutation steps match exactly.

## Files

- `root.zig`: Main module exports
- `plonky3_field.zig`: KoalaBear field implementation
- `poseidon2.zig`: Poseidon2 permutation implementation

