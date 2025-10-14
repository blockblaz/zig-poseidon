const std = @import("std");
const poseidon2 = @import("../poseidon2/poseidon2.zig");
const koalabear = @import("../fields/koalabear/montgomery.zig").MontgomeryField;

const WIDTH = 24;
const EXTERNAL_ROUNDS = 8;
const INTERNAL_ROUNDS = 23; // KoalaBear width-24 has 23 internal rounds
const SBOX_DEGREE = 3; // KoalaBear uses S-Box degree 3

// Diagonal for KoalaBear24 (from plonky3):
// V = [-2, 1, 2, 1/2, 3, 4, -1/2, -3, -4, 1/2^8, 1/4, 1/8, 1/16, 1/32, 1/64, 1/2^24,
//      -1/2^8, -1/8, -1/16, -1/32, -1/64, -1/2^7, -1/2^9, -1/2^24]
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
    parseHex("1fc00000"), // 1/4
    parseHex("0fe00000"), // 1/8
    parseHex("07f00000"), // 1/16
    parseHex("03f80000"), // 1/32
    parseHex("01fc0000"), // 1/64
    parseHex("00000080"), // 1/2^24
    parseHex("7f00ffff"), // -1/2^8
    parseHex("70200001"), // -1/8
    parseHex("78000001"), // -1/16
    parseHex("7c000001"), // -1/32
    parseHex("7e000001"), // -1/64
    parseHex("7f010000"), // -1/2^7
    parseHex("7f008000"), // -1/2^9
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

// External round constants from plonky3 KoalaBear width-24 (8 rounds: 4 initial + 4 final)
const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{ // Round 0 (initial)
        parseHex("1d050e2c"), parseHex("6cf27aed"), parseHex("6280e94d"), parseHex("267f7d1d"),
        parseHex("3e38f61e"), parseHex("032d3068"), parseHex("5a90f75c"), parseHex("015a0f76"),
        parseHex("6967d6dc"), parseHex("0dbbea00"), parseHex("5889b859"), parseHex("2a05f0ee"),
        parseHex("553a8e55"), parseHex("651ea135"), parseHex("5477b8cf"), parseHex("42713618"),
        parseHex("3e7a4c3c"), parseHex("345aea59"), parseHex("2c03c6b9"), parseHex("0ed91594"),
        parseHex("5f7f5289"), parseHex("017726de"), parseHex("0ea1e531"), parseHex("15ba6952"),
    },
    .{ // Round 1 (initial)
        parseHex("6f81ba22"), parseHex("6e876b46"), parseHex("71eee23a"), parseHex("31d5c653"),
        parseHex("21267e2f"), parseHex("150446ab"), parseHex("1eb8e60e"), parseHex("3a05fa0b"),
        parseHex("38df4871"), parseHex("440b2f96"), parseHex("6b02c356"), parseHex("243d8052"),
        parseHex("6ddf3198"), parseHex("78dfceaa"), parseHex("4be36ceb"), parseHex("3d4df117"),
        parseHex("75e90790"), parseHex("395cf215"), parseHex("26db3e24"), parseHex("7da12029"),
        parseHex("0cb9cebf"), parseHex("0567a770"), parseHex("5bdb20f6"), parseHex("1356ddce"),
    },
    .{ // Round 2 (initial)
        parseHex("523e3332"), parseHex("4c08a97f"), parseHex("7ec2b4a6"), parseHex("29b9f6bd"),
        parseHex("5a8d9b8f"), parseHex("6af9e67e"), parseHex("08a1cab2"), parseHex("4e6c72e6"),
        parseHex("6f7aa8bd"), parseHex("584ea34b"), parseHex("42db0d50"), parseHex("36a3c62a"),
        parseHex("6f4e95fb"), parseHex("19e79a1f"), parseHex("11f08016"), parseHex("3d80c7b4"),
        parseHex("52736b1f"), parseHex("51db7fb6"), parseHex("04a85c13"), parseHex("38d618f6"),
        parseHex("3ea9cfa0"), parseHex("4b1bad2b"), parseHex("65d90f9f"), parseHex("6816bd24"),
    },
    .{ // Round 3 (initial)
        parseHex("2343b4c7"), parseHex("325f4080"), parseHex("055f01fa"), parseHex("17bb3a53"),
        parseHex("146a31c1"), parseHex("261e7e62"), parseHex("2e769679"), parseHex("16bc52bf"),
        parseHex("104e47fe"), parseHex("26c50e91"), parseHex("306b64fc"), parseHex("01d6e875"),
        parseHex("2ca33222"), parseHex("01cb0a48"), parseHex("2b6e6a59"), parseHex("2dab6e3f"),
        parseHex("20e04a6b"), parseHex("2ead4396"), parseHex("2b013abc"), parseHex("1ace7fc3"),
        parseHex("29722b61"), parseHex("16018c9f"), parseHex("1cd2e9d7"), parseHex("31e82356"),
    },
    .{ // Round 4 (final)
        parseHex("139e28ca"), parseHex("5dcd4b89"), parseHex("52007c17"), parseHex("133c42e9"),
        parseHex("39af83b3"), parseHex("45e4fcc5"), parseHex("75c3cf54"), parseHex("59a58639"),
        parseHex("700f956b"), parseHex("02671e29"), parseHex("44c7f0dc"), parseHex("2215b19f"),
        parseHex("51409c03"), parseHex("5921e3cf"), parseHex("67464618"), parseHex("397e1773"),
        parseHex("2d6e7df8"), parseHex("70823ae7"), parseHex("3b40ea7d"), parseHex("2ad0663c"),
        parseHex("0cb558a7"), parseHex("23f0f8b8"), parseHex("3df76ea9"), parseHex("7d29aec9"),
    },
    .{ // Round 5 (final)
        parseHex("389b4187"), parseHex("257bc0b1"), parseHex("4596d6fb"), parseHex("0d4f6502"),
        parseHex("5b03e9bf"), parseHex("3bf32bc9"), parseHex("7c4d1e67"), parseHex("6627f196"),
        parseHex("2c02da3a"), parseHex("0ad3ab11"), parseHex("5fb1c9b2"), parseHex("090c6af2"),
        parseHex("097e898b"), parseHex("07553c05"), parseHex("06a9fc45"), parseHex("43b65edf"),
        parseHex("1e8db134"), parseHex("17f9adff"), parseHex("4e8d38b2"), parseHex("0d9876d8"),
        parseHex("0b6b33b6"), parseHex("4e95997c"), parseHex("14d75737"), parseHex("2c56c8e3"),
    },
    .{ // Round 6 (final)
        parseHex("229e77aa"), parseHex("23cc39df"), parseHex("20368ae5"), parseHex("231df374"),
        parseHex("162ce741"), parseHex("0435fe23"), parseHex("27aac3bb"), parseHex("16c3613e"),
        parseHex("2786997a"), parseHex("00f81e2d"), parseHex("1a981f0b"), parseHex("2343e351"),
        parseHex("29ce7fef"), parseHex("131f0240"), parseHex("22c94593"), parseHex("28b33e32"),
        parseHex("0fad1add"), parseHex("60b4a4be"), parseHex("2a9ad1b9"), parseHex("2b3002d9"),
        parseHex("65313676"), parseHex("5fdc26a4"), parseHex("408d1a5d"), parseHex("291e6e7e"),
    },
    .{ // Round 7 (final)
        parseHex("021ff023"), parseHex("138a1240"), parseHex("0e311f53"), parseHex("257b1aaf"),
        parseHex("07261fc2"), parseHex("0314803b"), parseHex("2116f6f8"), parseHex("20b26b1c"),
        parseHex("05665b94"), parseHex("05f3f247"), parseHex("2e56bc50"), parseHex("2dd09124"),
        parseHex("140ab0bc"), parseHex("08b4c979"), parseHex("1def1997"), parseHex("1b71e60d"),
        parseHex("31e9b6e5"), parseHex("6b7e64ea"), parseHex("30d86629"), parseHex("34dafad9"),
        parseHex("5e49bd32"), parseHex("4fe3cb3c"), parseHex("01a97a4c"), parseHex("14cd43db"),
    },
};

// Internal round constants from plonky3 KoalaBear width-24 (23 rounds)
const INTERNAL_RCS = [INTERNAL_ROUNDS]u32{
    parseHex("353ef11f"), parseHex("180d911f"), parseHex("514bd047"), parseHex("6317e349"),
    parseHex("001f2e7a"), parseHex("7dac1d74"), parseHex("37871e8e"), parseHex("7cb4d14e"),
    parseHex("242d6f0f"), parseHex("0b07bd7d"), parseHex("386304f0"), parseHex("507b004e"),
    parseHex("60e39ce0"), parseHex("0748e068"), parseHex("34869de1"), parseHex("08a53a5e"),
    parseHex("3f246984"), parseHex("5806f3cd"), parseHex("13fd66f2"), parseHex("61c35b2a"),
    parseHex("68cf3dcf"), parseHex("5c7a03aa"), parseHex("289efdfe"),
};

fn parseHex(s: []const u8) u32 {
    @setEvalBranchQuota(100_000);
    return std.fmt.parseInt(u32, s, 16) catch @compileError("OOM");
}

// Test to verify correctness against plonky3 test vector
test "koalabear24 plonky3 test vector" {
    @setEvalBranchQuota(100_000);

    const finite_fields = [_]type{
        @import("../fields/koalabear/montgomery.zig").MontgomeryField,
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

        // Test vector from plonky3 test_poseidon2_width_24_random
        const input_state = [WIDTH]u32{
            886409618,  1327899896, 1902407911, 591953491,  648428576,  1844789031,
            1198336108, 355597330,  1799586834, 59617783,   790334801,  1968791836,
            559272107,  31054313,   1042221543, 474748436,  135686258,  263665994,
            1962340735, 1741539604, 2026927696, 449439011,  1131357108, 50869465,
        };

        const expected = [WIDTH]u32{
            3825456,    486989921,  613714063,  282152282,  1027154688, 1171655681,
            879344953,  1090688809, 1960721991, 1604199242, 1329947150, 1535171244,
            781646521,  1156559780, 1875690339, 368140677,  457503063,  304208551,
            1919757655, 835116474,  1293372648, 1254825008, 810923913,  1773631109,
        };

        const output_state = testPermutation(TestPoseidon2KoalaBear, input_state);

        // Verify it matches plonky3 output
        try std.testing.expectEqual(expected, output_state);
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

