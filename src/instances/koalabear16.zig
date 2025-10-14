const std = @import("std");
const poseidon2 = @import("../poseidon2/poseidon2.zig");
const koalabear = @import("../fields/koalabear/montgomery.zig").MontgomeryField;

const WIDTH = 16;
const EXTERNAL_ROUNDS = 8;
const INTERNAL_ROUNDS = 20; // KoalaBear has 20 internal rounds (vs 13 for BabyBear)
const SBOX_DEGREE = 3; // KoalaBear uses S-Box degree 3 (vs 7 for BabyBear)

// Optimized Diagonal for KoalaBear16:
// [-2, 1, 2, 1/2, 3, 4, -1/2, -3, -4, 1/2^8, 1/8, 1/2^24, -1/2^8, -1/8, -1/16, -1/2^24]
// These are the actual field element values in KoalaBear field (mod 0x7f000001)
const DIAGONAL = [WIDTH]u32{
    parseHex("7efffffe"), // -2
    parseHex("00000001"), // 1
    parseHex("00000002"), // 2
    parseHex("3f800001"), // 1/2
    parseHex("00000003"), // 3
    parseHex("00000004"), // 4
    parseHex("3f800000"), // -1/2
    parseHex("7ffffffd"), // -3
    parseHex("7ffffffc"), // -4
    parseHex("007f0000"), // 1/2^8
    parseHex("0fe00000"), // 1/8
    parseHex("00000080"), // 1/2^24
    parseHex("7f00ffff"), // -1/2^8
    parseHex("70200001"), // -1/8
    parseHex("78000001"), // -1/16
    parseHex("7fffff7f"), // -1/2^24
};

pub const Poseidon2KoalaBear = poseidon2.Poseidon2(
    koalabear,
    WIDTH,
    INTERNAL_ROUNDS,
    EXTERNAL_ROUNDS,
    SBOX_DEGREE,
    DIAGONAL,
    EXTERNAL_RCS,
    INTERNAL_RCS,
);

// External round constants from plonky3 KoalaBear (8 rounds)
const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{ // Round 0
        parseHex("7ee85058"), parseHex("1133f10b"), parseHex("12dc4a5e"), parseHex("7ec8fa25"),
        parseHex("196c9975"), parseHex("66399548"), parseHex("3e407156"), parseHex("67b5de45"),
        parseHex("350a5dbb"), parseHex("00871aa4"), parseHex("289c911a"), parseHex("18fabc32"),
        parseHex("5f2ff071"), parseHex("5e649e78"), parseHex("5e796f77"), parseHex("5b2ec640"),
    },
    .{ // Round 1
        parseHex("6eff9cdf"), parseHex("3fe00eb9"), parseHex("1edde4e4"), parseHex("573fa11e"),
        parseHex("43dca755"), parseHex("1980026f"), parseHex("0e9f5939"), parseHex("61e1cd1b"),
        parseHex("515ab3a0"), parseHex("2deb5abc"), parseHex("2951d871"), parseHex("2d2bb057"),
        parseHex("082aa92f"), parseHex("19fec576"), parseHex("1f536853"), parseHex("5ce40a82"),
    },
    .{ // Round 2
        parseHex("3d67d0ae"), parseHex("33e0eae6"), parseHex("133b477e"), parseHex("0fefe1cd"),
        parseHex("388d3cb1"), parseHex("2c22ff1f"), parseHex("2886bd52"), parseHex("06c31742"),
        parseHex("7b2f1d1c"), parseHex("67d30aea"), parseHex("15e08fe0"), parseHex("52476fba"),
        parseHex("6dd3f060"), parseHex("18d5e6de"), parseHex("50064d22"), parseHex("64ed91ce"),
    },
    .{ // Round 3
        parseHex("59065367"), parseHex("425cfd60"), parseHex("0c92b0f2"), parseHex("3fdf1995"),
        parseHex("245c38b9"), parseHex("43a9f8be"), parseHex("7869e169"), parseHex("3cc080bf"),
        parseHex("2873a5ae"), parseHex("64090a2d"), parseHex("51315f76"), parseHex("03a5ed29"),
        parseHex("48125d82"), parseHex("03d64e64"), parseHex("736f9f17"), parseHex("760ba77f"),
    },
    .{ // Round 4 (first of final 4 rounds)
        parseHex("54e6667d"), parseHex("7d3a8ab6"), parseHex("72302c56"), parseHex("106671b3"),
        parseHex("459a4b5b"), parseHex("440dd9c5"), parseHex("153c8625"), parseHex("456e506a"),
        parseHex("4eabe6ce"), parseHex("379b805f"), parseHex("47c3d31c"), parseHex("569a3b4c"),
        parseHex("69eb2aa9"), parseHex("373c7f5c"), parseHex("469eab88"), parseHex("46ad8d2a"),
    },
    .{ // Round 5
        parseHex("3237d84b"), parseHex("0b070193"), parseHex("1af12707"), parseHex("1e5f2b92"),
        parseHex("43e68124"), parseHex("2593cec1"), parseHex("27e10d8b"), parseHex("1b9059ea"),
        parseHex("3438fa28"), parseHex("485f3302"), parseHex("16da7b55"), parseHex("16544216"),
        parseHex("25f1d419"), parseHex("124f0185"), parseHex("17420359"), parseHex("773d52d5"),
    },
    .{ // Round 6
        parseHex("5a80106a"), parseHex("5fccf1df"), parseHex("540e7ae5"), parseHex("5e55f374"),
        parseHex("3bcc5f41"), parseHex("088ffc23"), parseHex("682076bb"), parseHex("3c99273e"),
        parseHex("682ede7a"), parseHex("03f4782d"), parseHex("46347d0b"), parseHex("5e44cf51"),
        parseHex("6e61ffef"), parseHex("32d45a40"), parseHex("594b9f93"), parseHex("6c2e8e32"),
    },
    .{ // Round 7
        parseHex("08f8dc35"), parseHex("34c27f40"), parseHex("24e888d3"), parseHex("626d30af"),
        parseHex("1e278386"), parseHex("0ca50f3b"), parseHex("586aebf8"), parseHex("56ebed9c"),
        parseHex("16ce4334"), parseHex("18de5047"), parseHex("7b364850"), parseHex("76f13b24"),
        parseHex("35caec3c"), parseHex("22ca35f5"), parseHex("4fb452f7"), parseHex("477c45cd"),
    },
};

// Internal round constants from plonky3 KoalaBear (20 rounds)
const INTERNAL_RCS = [INTERNAL_ROUNDS]u32{
    parseHex("7d534856"), parseHex("5b5d07dd"), parseHex("5599ba48"), parseHex("77f1ce88"),
    parseHex("320baaeb"), parseHex("490cec7a"), parseHex("77e7d3df"), parseHex("224fd61b"),
    parseHex("4e0c1451"), parseHex("2edbe709"), parseHex("3b543710"), parseHex("65891c21"),
    parseHex("56183a2a"), parseHex("3628fc37"), parseHex("6bcd3ced"), parseHex("5b3ee7ff"),
    parseHex("617ede5e"), parseHex("5e809cab"), parseHex("3396e313"), parseHex("345f5e5a"),
};

fn parseHex(s: []const u8) u32 {
    @setEvalBranchQuota(100_000);
    return std.fmt.parseInt(u32, s, 16) catch @compileError("OOM");
}

// Test vectors to verify correctness
// These should match the outputs from plonky3 KoalaBear implementation
test "koalabear16 zero state" {
    @setEvalBranchQuota(100_000);

    const finite_fields = [_]type{
        @import("../fields/koalabear/montgomery.zig").MontgomeryField,
        @import("../fields/koalabear/naive.zig"),
    };
    inline for (finite_fields) |F| {
        const TestPoseidon2KoalaBear = poseidon2.Poseidon2(
            F,
            WIDTH,
            INTERNAL_ROUNDS,
            EXTERNAL_ROUNDS,
            SBOX_DEGREE,
            DIAGONAL,
            EXTERNAL_RCS,
            INTERNAL_RCS,
        );

        // Test with zero input
        const input_state = std.mem.zeroes([WIDTH]u32);
        const output_state = testPermutation(TestPoseidon2KoalaBear, input_state);

        // Just verify it runs without crashing for now
        // We'll add exact test vectors once we verify against plonky3
        try std.testing.expect(output_state[0] != 0); // Should produce non-zero output
    }
}

test "koalabear16 constant input" {
    @setEvalBranchQuota(100_000);

    const finite_fields = [_]type{
        @import("../fields/koalabear/montgomery.zig").MontgomeryField,
        @import("../fields/koalabear/naive.zig"),
    };
    inline for (finite_fields) |F| {
        const TestPoseidon2KoalaBear = poseidon2.Poseidon2(
            F,
            WIDTH,
            INTERNAL_ROUNDS,
            EXTERNAL_ROUNDS,
            SBOX_DEGREE,
            DIAGONAL,
            EXTERNAL_RCS,
            INTERNAL_RCS,
        );

        // Test with constant input (all elements = 42)
        const input_state = [_]F.FieldElem{42} ** WIDTH;
        const output_state = testPermutation(TestPoseidon2KoalaBear, input_state);

        // Verify non-trivial output
        try std.testing.expect(output_state[0] != 42); // Should transform the input
    }
}

test "koalabear16 field implementation coherency" {
    @setEvalBranchQuota(100_000);

    const Poseidon2KoalaBearNaive = poseidon2.Poseidon2(
        @import("../fields/koalabear/naive.zig"),
        WIDTH,
        INTERNAL_ROUNDS,
        EXTERNAL_ROUNDS,
        SBOX_DEGREE,
        DIAGONAL,
        EXTERNAL_RCS,
        INTERNAL_RCS,
    );
    const Poseidon2KoalaBearOptimized = poseidon2.Poseidon2(
        @import("../fields/koalabear/montgomery.zig").MontgomeryField,
        WIDTH,
        INTERNAL_ROUNDS,
        EXTERNAL_ROUNDS,
        SBOX_DEGREE,
        DIAGONAL,
        EXTERNAL_RCS,
        INTERNAL_RCS,
    );

    // Test that naive and optimized implementations produce identical results
    var rand = std.Random.DefaultPrng.init(42);
    for (0..1_000) |_| {
        var input_state: [WIDTH]u32 = undefined;
        for (0..WIDTH) |index| {
            // Keep values in KoalaBear field range
            input_state[index] = @truncate(rand.next() % (127 * (1 << 24) + 1));
        }

        const naive_output = testPermutation(Poseidon2KoalaBearNaive, input_state);
        const optimized_output = testPermutation(Poseidon2KoalaBearOptimized, input_state);

        try std.testing.expectEqual(naive_output, optimized_output);
    }
}

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
