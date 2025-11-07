// Poseidon2 implementation compatible with Plonky3 KoalaBear field

pub const Field = @import("plonky3_field.zig").KoalaBearField;
pub const Poseidon2KoalaBear16 = @import("poseidon2.zig").Poseidon2KoalaBear16Plonky3;
pub const Poseidon2KoalaBear16Plonky3 = @import("poseidon2.zig").Poseidon2KoalaBear16Plonky3;
pub const Poseidon2KoalaBear24 = @import("poseidon2.zig").Poseidon2KoalaBear24Plonky3;
pub const Poseidon2KoalaBear24Plonky3 = @import("poseidon2.zig").Poseidon2KoalaBear24Plonky3;

pub const poseidon2_16 = @import("poseidon2.zig").poseidon2_16_plonky3;
pub const poseidon2_24 = @import("poseidon2.zig").poseidon2_24_plonky3;
pub const sbox = @import("poseidon2.zig").sbox;
pub const apply_mat4 = @import("poseidon2.zig").apply_mat4;
pub const mds_light_permutation_16 = @import("poseidon2.zig").mds_light_permutation_16;
pub const mds_light_permutation_24 = @import("poseidon2.zig").mds_light_permutation_24;
pub const apply_internal_layer_16 = @import("poseidon2.zig").apply_internal_layer_16;
pub const apply_internal_layer_24 = @import("poseidon2.zig").apply_internal_layer_24;
pub const apply_external_layer_16 = @import("poseidon2.zig").apply_external_layer_16;
pub const apply_external_layer_24 = @import("poseidon2.zig").apply_external_layer_24;

pub const PLONKY3_KOALABEAR_RC16_EXTERNAL_INITIAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC16_EXTERNAL_INITIAL;
pub const PLONKY3_KOALABEAR_RC16_EXTERNAL_FINAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC16_EXTERNAL_FINAL;
pub const PLONKY3_KOALABEAR_RC16_INTERNAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC16_INTERNAL;
pub const PLONKY3_KOALABEAR_RC24_EXTERNAL_INITIAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC24_EXTERNAL_INITIAL;
pub const PLONKY3_KOALABEAR_RC24_EXTERNAL_FINAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC24_EXTERNAL_FINAL;
pub const PLONKY3_KOALABEAR_RC24_INTERNAL = @import("poseidon2.zig").PLONKY3_KOALABEAR_RC24_INTERNAL;

