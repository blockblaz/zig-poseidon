// KoalaBear field: p = 2^31 - 2^24 + 1 = 127 * 2^24 + 1 = 2130706433 = 0x7f000001
// This field is used in plonky3 and Rust hash-sig implementations
pub const MontgomeryField = @import("../generic_montgomery.zig").MontgomeryField31(127 * (1 << 24) + 1);
