const std = @import("std");
const poseidon2 = @import("../poseidon2/poseidon2.zig");
pub const kolabear = @import("../fields/koalabear/montgomery.zig").MontgomeryField;

const WIDTH = 16;
const EXTERNAL_ROUNDS = 8;
const INTERNAL_ROUNDS = 20;
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
   1864368129, 
   2130706306, 
   8323072, 
   266338304, 
   133169152, 
   127    
};

const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },    
    .{ 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },   
    .{ 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47 },   
    .{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63 },    
    .{ 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 },    
    .{ 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95 },  
    .{ 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111 },    
    .{ 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127 }};

const INTERNAL_RCS =[INTERNAL_ROUNDS]u32{128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,144, 145, 146, 147};

 pub const Poseidon2Kolabear = poseidon2.Poseidon2(
    kolabear,
    WIDTH,
    INTERNAL_ROUNDS,
    EXTERNAL_ROUNDS,
    SBOX_DEGREE,
    DIAGONAL,
    EXTERNAL_RCS,
    INTERNAL_RCS,
);

// const EXTERNAL_RCS = blk: {
//     var rcs: [EXTERNAL_ROUNDS][WIDTH]u32 = undefined;
//     var k: u32 = 0;
//     for (0..EXTERNAL_ROUNDS) |i| {
//         for (0..WIDTH) |j| {
//             rcs[i][j] = k;
//             k += 1;
//         }
//     }
//     break :blk rcs;
// };

// const INTERNAL_RCS = blk: {
//     var rcs: [INTERNAL_ROUNDS]u32 = undefined;
//     var k: u32 = EXTERNAL_ROUNDS * WIDTH;
//     for (0..INTERNAL_ROUNDS) |i| {
//         rcs[i] = k;
//         k += 1;
//     }
//     break :blk rcs;
// };

// Tests vectors were generated from the Poseidon2 reference repository: github.com/HorizenLabs/poseidon2
const testVector = struct {
    input_state: [WIDTH]u32,
    output_state: [WIDTH]u32,
};


// test "reference repo" {
//     @setEvalBranchQuota(100_000);

//     const finite_fields = [_]type{
//         @import("../fields/babybear/montgomery.zig").MontgomeryField,
//         @import("../fields/babybear/naive.zig"),
//     };
//     inline for (finite_fields) |F| {
//         const TestPoseidon2BabyBear = poseidon2.Poseidon2(
//             F,
//             WIDTH,
//             INTERNAL_ROUNDS,
//             EXTERNAL_ROUNDS,
//             SBOX_DEGREE,
//             DIAGONAL,
//             EXTERNAL_RCS,
//             INTERNAL_RCS,
//         );
//         const tests_vectors = [_]testVector{
//             .{
//                 .input_state = std.mem.zeroes([WIDTH]u32),
//                 .output_state = .{ 1337856655, 1843094405, 328115114, 964209316, 1365212758, 1431554563, 210126733, 1214932203, 1929553766, 1647595522, 1496863878, 324695999, 1569728319, 1634598391, 597968641, 679989771 },
//             },
//             .{
//                 .input_state = [_]F.FieldElem{42} ** 16,
//                 .output_state = .{ 1000818763, 32822117, 1516162362, 1002505990, 932515653, 770559770, 350012663, 846936440, 1676802609, 1007988059, 883957027, 738985594, 6104526, 338187715, 611171673, 414573522 },
//             },
//         };
//         for (tests_vectors) |test_vector| {
//             try std.testing.expectEqual(test_vector.output_state, testPermutation(TestPoseidon2BabyBear, test_vector.input_state));
//         }
//     }
// }

// test "finite field implementation coherency" {
//     const Poseidon2BabyBearNaive = poseidon2.Poseidon2(
//         @import("../fields/babybear/naive.zig"),
//         WIDTH,
//         INTERNAL_ROUNDS,
//         EXTERNAL_ROUNDS,
//         SBOX_DEGREE,
//         DIAGONAL,
//         EXTERNAL_RCS,
//         INTERNAL_RCS,
//     );
//     const Poseidon2BabyBearOptimized = poseidon2.Poseidon2(
//         @import("../fields/babybear/montgomery.zig").MontgomeryField,
//         WIDTH,
//         INTERNAL_ROUNDS,
//         EXTERNAL_ROUNDS,
//         SBOX_DEGREE,
//         DIAGONAL,
//         EXTERNAL_RCS,
//         INTERNAL_RCS,
//     );
//     var rand = std.Random.DefaultPrng.init(42);
//     for (0..10_000) |_| {
//         var input_state: [WIDTH]u32 = undefined;
//         for (0..WIDTH) |index| {
//             input_state[index] = @truncate(rand.next());
//         }

//         try std.testing.expectEqual(testPermutation(Poseidon2BabyBearNaive, input_state), testPermutation(Poseidon2BabyBearOptimized, input_state));
//     }
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
