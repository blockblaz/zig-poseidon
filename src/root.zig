// Root module for zig-poseidon
// Re-exports all components

pub const babybear16 = @import("instances/babybear16.zig");
pub const koalabear16 = @import("instances/koalabear16.zig");
pub const poseidon2 = @import("poseidon2/poseidon2.zig");

// Convenience type exports
pub const Poseidon2BabyBear = babybear16.Poseidon2BabyBear;
pub const Poseidon2KoalaBear = koalabear16.Poseidon2KoalaBear;

test {
    @import("std").testing.refAllDecls(@This());
}
