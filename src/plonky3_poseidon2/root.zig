// Poseidon2 implementation compatible with Plonky3 KoalaBear field

const koalabear16 = @import("../instances/koalabear16_generic.zig");
const koalabear24 = @import("../instances/koalabear24_generic.zig");
const MontgomeryField = @import("../fields/koalabear/montgomery.zig").MontgomeryField;

pub const Field = MontgomeryField;

pub const Poseidon2KoalaBear16Plonky3 = koalabear16.Poseidon2KoalaBear;
pub const Poseidon2KoalaBear24Plonky3 = koalabear24.Poseidon2KoalaBear;
pub const Poseidon2KoalaBear16 = Poseidon2KoalaBear16Plonky3;
pub const Poseidon2KoalaBear24 = Poseidon2KoalaBear24Plonky3;

pub fn poseidon2_16(state: *[16]Field.MontFieldElem) void {
    Poseidon2KoalaBear16Plonky3.permutation(state);
}

pub fn poseidon2_24(state: *[24]Field.MontFieldElem) void {
    Poseidon2KoalaBear24Plonky3.permutation(state);
}
