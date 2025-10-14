// Root module for zig-poseidon
// Re-exports all components

pub const babybear16 = @import("instances/babybear16.zig");
pub const koalabear16 = @import("instances/koalabear16.zig");
pub const koalabear24 = @import("instances/koalabear24.zig");
pub const poseidon2 = @import("poseidon2/poseidon2.zig");

// Convenience type exports
pub const Poseidon2BabyBear = babybear16.Poseidon2BabyBear;
pub const Poseidon2KoalaBear16 = koalabear16.Poseidon2KoalaBear;
pub const Poseidon2KoalaBear24 = koalabear24.Poseidon2KoalaBear;

test {
    @import("std").testing.refAllDecls(@This());
}
