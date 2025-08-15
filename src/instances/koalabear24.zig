const std = @import("std");
const poseidon2 = @import("../poseidon2/poseidon2.zig");
pub const koalabear = @import("../fields/koalabear/montgomery.zig").MontgomeryField;

const WIDTH = 24;
const EXTERNAL_ROUNDS = 8;
const INTERNAL_ROUNDS = 23;
const SBOX_DEGREE = 3;

const DIAGONAL = [WIDTH]u32{
 2130706431, 
 1, 
 2, 
 1065353217, 
 3, 
 4, 
 1065353216, 
 2130706430,   
 2130706429, 
 2122383361, 
 1598029825, 
 1864368129, 
 1997537281, 
 2064121857, 
 2097414145, 
 2130706306,
 8323072, 
 266338304, 
 133169152, 
 66584576, 
 33292288, 
 16646144, 
 4161536, 
 127
};

const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 },
    .{ 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47 },    
    .{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71 },    
    .{ 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95 },    
    .{ 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119 }, 
    .{ 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143 },    
    .{ 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167 },    
    .{ 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191 }};
   
const INTERNAL_RCS = [INTERNAL_ROUNDS]u32{     
    192, 193, 194, 195, 196, 197, 198, 199,  
    200, 201, 202, 203, 204, 205, 206, 207,    
    208, 209, 210, 211, 212, 213, 214,};


pub const Poseidon2KoalaBearOptimized = poseidon2.Poseidon2(
    koalabear,
    WIDTH,
    INTERNAL_ROUNDS,
    EXTERNAL_ROUNDS,
    SBOX_DEGREE,
    DIAGONAL,
    EXTERNAL_RCS,
    INTERNAL_RCS,
);

// test "finite field implementation coherency" {
//     const input_state = [WIDTH]u32{
//         0, 1, 2, 3, 4, 5, 6, 7,
//         8, 9, 10, 11, 12, 13, 14, 15,
//         16, 17, 18, 19, 20, 21, 22, 23,
//     };
//     try std.testing.expectEqual(
//         testPermutation(Poseidon2KoalaBearNaive, input_state),
//         testPermutation(Poseidon2KoalaBearOptimized, input_state),
//     );
// }

fn testPermutation(comptime Poseidon2: type, state: [WIDTH]u32) [WIDTH]u32 {
    const F = Poseidon2.Field;
    var mont_state: [WIDTH]F.MontFieldElem = undefined;
    inline for (0..WIDTH) |j| {
        F.toMontgomery(&mont_state[j], state[j]);
    }
    Poseidon2.permutation(&mont_state);
    var ret: [WIDTH]u32 = undefined;
    inline for (0..WIDTH) |j| {
        ret[j] = F.toNormal(mont_state[j]);
    }
    return ret;
}