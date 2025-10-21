// Root module for zig-poseidon
// Re-exports all components

pub const babybear16 = @import("instances/babybear16.zig");
pub const koalabear = @import("instances/koalabear.zig");
pub const koalabear16_generic = @import("instances/koalabear16_generic.zig");
pub const koalabear24_generic = @import("instances/koalabear24_generic.zig");
pub const poseidon2 = @import("poseidon2/poseidon2.zig");

// Convenience type exports
pub const Poseidon2BabyBear = babybear16.Poseidon2BabyBear;

// Primary Rust-compatible KoalaBear instances (recommended)
pub const Poseidon2KoalaBear = koalabear.Poseidon2KoalaBearRustCompat;
pub const Poseidon2KoalaBear16 = koalabear.Poseidon2KoalaBearRustCompat;
pub const Poseidon2KoalaBear24 = koalabear.Poseidon2KoalaBearRustCompat;
pub const Poseidon2KoalaBearRustCompat = koalabear.Poseidon2KoalaBearRustCompat;
pub const Poseidon2KoalaBearRustCompat2_18 = koalabear.Poseidon2KoalaBearRustCompat2_18;
pub const Poseidon2KoalaBearRustCompat2_20 = koalabear.Poseidon2KoalaBearRustCompat2_20;
pub const Poseidon2KoalaBearRustCompat2_32 = koalabear.Poseidon2KoalaBearRustCompat2_32;
pub const TargetSumEncoding = koalabear.TargetSumEncoding;
pub const TopLevelPoseidonMessageHash = koalabear.TopLevelPoseidonMessageHash;

// Generic instances (for backward compatibility)
pub const Poseidon2KoalaBear16Generic = koalabear16_generic.Poseidon2KoalaBear;
pub const Poseidon2KoalaBear24Generic = koalabear24_generic.Poseidon2KoalaBear;

test {
    @import("std").testing.refAllDecls(@This());
}
