# poseidon

A Zig implementation of the Poseidon2 cryptographic hash function.

## Supported Configurations

This implementation provides:

### Finite Fields

- **BabyBear field** (p = 2³¹ - 2²⁷ + 1 = 0x78000001)
  - Width: 16 elements
  - S-Box degree: 7
  - Internal rounds: 13
  - External rounds: 8
  - Use case: Ethereum Lean chain

- **KoalaBear field** (p = 2³¹ - 2²⁴ + 1 = 0x7f000001)  
  - Width: 16 elements
  - S-Box degree: 3
  - Internal rounds: 20
  - External rounds: 8
  - Use case: plonky3, Rust hash-sig compatibility

### Features

- Generic Montgomery form implementation for finite fields of 31 bits or less
- Compression mode (recommended for Merkle Trees)
- Both naive and optimized (Montgomery) implementations for verification
- Comprehensive test suite ensuring consistency between implementations

## Installation

Add `zig-poseidon` as a dependency in your `build.zig.zon`:

```zig
.dependencies = .{
    .poseidon = .{
        .url = "https://github.com/blockblaz/zig-poseidon/archive/v0.2.0.tar.gz",
        .hash = "122...", // Get hash by running: zig fetch --save <url>
    },
},
```

**Get the correct hash:**
```bash
zig fetch --save https://github.com/blockblaz/zig-poseidon/archive/v0.2.0.tar.gz
```

**Latest version:** See [Releases](https://github.com/blockblaz/zig-poseidon/releases) for the most recent version.

## Usage

### Using BabyBear16

```zig
const std = @import("std");
const babybear16 = @import("babybear16");

pub fn main() !void {
    const Field = babybear16.Poseidon2BabyBear.Field;
    
    // Prepare input state (16 field elements)
    var input_state: [16]u32 = .{0} ** 16;
    input_state[0] = 42;
    
    // Convert to Montgomery form
    var mont_state: [16]Field.MontFieldElem = undefined;
    for (0..16) |i| {
        Field.toMontgomery(&mont_state[i], input_state[i]);
    }
    
    // Apply permutation
    babybear16.Poseidon2BabyBear.permutation(&mont_state);
    
    // Convert back to normal form
    var output_state: [16]u32 = undefined;
    for (0..16) |i| {
        output_state[i] = Field.toNormal(mont_state[i]);
    }
    
    std.debug.print("Output: {any}\n", .{output_state});
}
```

### Using KoalaBear16 (Rust hash-sig compatible)

```zig
const std = @import("std");
const koalabear16 = @import("koalabear16");

pub fn main() !void {
    const Field = koalabear16.Poseidon2KoalaBear.Field;
    
    // Prepare input state (16 field elements)
    var input_state: [16]u32 = .{0} ** 16;
    input_state[0] = 42;
    
    // Convert to Montgomery form
    var mont_state: [16]Field.MontFieldElem = undefined;
    for (0..16) |i| {
        Field.toMontgomery(&mont_state[i], input_state[i]);
    }
    
    // Apply permutation
    koalabear16.Poseidon2KoalaBear.permutation(&mont_state);
    
    // Convert back to normal form
    var output_state: [16]u32 = undefined;
    for (0..16) |i| {
        output_state[i] = Field.toNormal(mont_state[i]);
    }
    
    std.debug.print("Output: {any}\n", .{output_state});
}
```

## Building and Testing

```bash
# Build the library
zig build

# Run all tests (includes BabyBear and KoalaBear)
zig build test
```

## Field Comparison

| Feature | BabyBear | KoalaBear |
|---------|----------|-----------|
| **Prime** | 2³¹ - 2²⁷ + 1 | 2³¹ - 2²⁴ + 1 |
| **Hex Value** | 0x78000001 | 0x7f000001 |
| **Width** | 16 | 16 |
| **S-Box Degree** | 7 | 3 |
| **Internal Rounds** | 13 | 20 |
| **External Rounds** | 8 | 8 |
| **Compatible With** | Ethereum Lean | plonky3, Rust hash-sig |

**Important:** Different fields produce completely different hash outputs! Choose the field that matches your target system.

## Project Motivation

This repository was created primarily to support the upcoming Ethereum Lean chain. The KoalaBear field was added to enable compatibility with Rust's hash-sig implementation and plonky3.

## Compatibility

- **BabyBear**: Cross-validated against the [Poseidon2 reference repository](https://github.com/HorizenLabs/poseidon2)
- **KoalaBear**: Compatible with [plonky3](https://github.com/Plonky3/Plonky3) and [Rust hash-sig](https://github.com/b-wagn/hash-sig)

Both implementations include tests ensuring the naive and optimized (Montgomery) implementations produce identical outputs.

## Future Enhancements

- Add support for more finite fields
- Add support for the sponge construction
- Add benchmarks and performance optimizations
- Add more S-Box degrees as needed

## Versioning and Releases

This project follows [Semantic Versioning](https://semver.org/). 

**Current version:** `0.2.0`

### Release Process

Releases are automatically created when Pull Requests from `main` are merged to the `release` branch:

1. Develop and merge features to `main` branch
2. When ready to release, update the `VERSION` file on `main`
3. Create a PR from `main` to `release` branch
4. After merge to `release`, the workflow automatically:
   - Creates a Git tag (e.g., `v0.2.0`)
   - Generates a changelog
   - Creates a GitHub Release
   - Calculates the tarball hash for dependencies

**Why a release branch?**
- ✅ Control when releases happen
- ✅ Not every feature triggers a release
- ✅ Batch multiple features into one release

See [RELEASING.md](RELEASING.md) for detailed release instructions.

### Using Specific Versions

Always pin to a specific version in your `build.zig.zon`:

```zig
.poseidon = .{
    .url = "https://github.com/blockblaz/zig-poseidon/archive/v0.2.0.tar.gz",
    .hash = "122...", // specific hash for v0.2.0
},
```

**Find releases:** [GitHub Releases](https://github.com/blockblaz/zig-poseidon/releases)

## License

MIT

## References

- [Poseidon2 Paper](https://eprint.iacr.org/2023/323)
- [HorizenLabs/poseidon2 Reference Implementation](https://github.com/HorizenLabs/poseidon2)
- [Plonky3](https://github.com/Plonky3/Plonky3)
- [Rust hash-sig](https://github.com/b-wagn/hash-sig)
