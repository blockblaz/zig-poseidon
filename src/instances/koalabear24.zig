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
    parseHex("7effffff"), // -2
    parseHex("00000001"), // 1
    parseHex("00000002"), // 2
    parseHex("3f800001"), // 1/2
    parseHex("00000003"), // 3
    parseHex("00000004"), // 4
    parseHex("3f800000"), // -1/2
    parseHex("7efffffe"), // -3
    parseHex("7efffffd"), // -4
    parseHex("7e810001"), // 1/2^8
    parseHex("5f400001"), // 1/4
    parseHex("6f200001"), // 1/8
    parseHex("77100001"), // 1/16
    parseHex("7b080001"), // 1/32
    parseHex("7d040001"), // 1/64
    parseHex("7effff82"), // 1/2^24
    parseHex("007f0000"), // -1/2^8
    parseHex("0fe00000"), // -1/8
    parseHex("07f00000"), // -1/16
    parseHex("03f80000"), // -1/32
    parseHex("01fc0000"), // -1/64
    parseHex("00fe0000"), // -1/2^7
    parseHex("003f8000"), // -1/2^9
    parseHex("0000007f"), // -1/2^24
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

// External round constants from plonky3 KoalaBear width-24
// 8 rounds total: 4 initial (beginning) + 4 final (end)
// Source: https://github.com/Plonky3/Plonky3/blob/main/koala-bear/src/poseidon2.rs
const EXTERNAL_RCS = [EXTERNAL_ROUNDS][WIDTH]u32{
    .{ // Round 0 (initial)
        parseHex("1d0939dc"), parseHex("6d050f8d"), parseHex("628058ad"), parseHex("2681385d"),
        parseHex("3e3c62be"), parseHex("032cfad8"), parseHex("5a91ba3c"), parseHex("015a56e6"),
        parseHex("696b889c"), parseHex("0dbcd780"), parseHex("5881b5c9"), parseHex("2a076f2e"),
        parseHex("55393055"), parseHex("6513a085"), parseHex("547ac78f"), parseHex("4281c5b8"),
        parseHex("3e7a3f6c"), parseHex("34562c19"), parseHex("2c04e679"), parseHex("0ed78234"),
        parseHex("5f7a1aa9"), parseHex("0177640e"), parseHex("0ea4f8d1"), parseHex("15be7692"),
    },
    .{ // Round 1 (initial)
        parseHex("6eafdd62"), parseHex("71a572c6"), parseHex("72416f0a"), parseHex("31ce1ad3"),
        parseHex("2136a0cf"), parseHex("1507c0eb"), parseHex("1eb6e07a"), parseHex("3a0ccf7b"),
        parseHex("38e4bf31"), parseHex("44128286"), parseHex("6b05e976"), parseHex("244a9b92"),
        parseHex("6e4b32a8"), parseHex("78ee2496"), parseHex("4761115b"), parseHex("3d3a7077"),
        parseHex("75d3c670"), parseHex("396a2475"), parseHex("26dd00b4"), parseHex("7df50f59"),
        parseHex("0cb922df"), parseHex("0568b190"), parseHex("5bd3fcd6"), parseHex("1351f58e"),
    },
    .{ // Round 2 (initial)
        parseHex("52191b5f"), parseHex("119171b8"), parseHex("1e8bb727"), parseHex("27d21f26"),
        parseHex("36146613"), parseHex("1ee817a2"), parseHex("71abe84e"), parseHex("44b88070"),
        parseHex("5dc04410"), parseHex("2aeaa2f6"), parseHex("2b7bb311"), parseHex("6906884d"),
        parseHex("0522e053"), parseHex("0c45a214"), parseHex("1b016998"), parseHex("479b1052"),
        parseHex("3acc89be"), parseHex("0776021a"), parseHex("7a34a1f5"), parseHex("70f87911"),
        parseHex("2caf9d9e"), parseHex("026aff1b"), parseHex("2c42468e"), parseHex("67726b45"),
    },
    .{ // Round 3 (initial)
        parseHex("09b6f53c"), parseHex("73d76589"), parseHex("5793eeb0"), parseHex("29e720f3"),
        parseHex("75fc8bdf"), parseHex("4c2fae0e"), parseHex("20b41db3"), parseHex("7e491510"),
        parseHex("2cadef18"), parseHex("57fc24d6"), parseHex("4d1ade4a"), parseHex("36bf8e3c"),
        parseHex("3511b63c"), parseHex("64d8476f"), parseHex("732ba706"), parseHex("46634978"),
        parseHex("0521c17c"), parseHex("5ee69212"), parseHex("3559cba9"), parseHex("2b33df89"),
        parseHex("653538d6"), parseHex("5fde8344"), parseHex("4091605d"), parseHex("2933bdde"),
    },
    .{ // Round 4 (final)
        parseHex("1395d4ca"), parseHex("5dbac049"), parseHex("51fc2727"), parseHex("13407399"),
        parseHex("39ac6953"), parseHex("45e8726c"), parseHex("75a7311c"), parseHex("599f82c9"),
        parseHex("702cf13b"), parseHex("026b8955"), parseHex("44e09bbc"), parseHex("2211207f"),
        parseHex("5128b4e3"), parseHex("591c41af"), parseHex("674f5c68"), parseHex("3981d0d3"),
        parseHex("2d82f898"), parseHex("707cd267"), parseHex("3b4cca45"), parseHex("2ad0dc3c"),
        parseHex("0cb79b37"), parseHex("23f2f4e8"), parseHex("3de4e739"), parseHex("7d232359"),
    },
    .{ // Round 5 (final)
        parseHex("389d82f9"), parseHex("259b2e6c"), parseHex("45a94def"), parseHex("0d497380"),
        parseHex("5b049135"), parseHex("3c268399"), parseHex("78feb2f9"), parseHex("300a3eec"),
        parseHex("505165bb"), parseHex("20300973"), parseHex("2327c081"), parseHex("1a45a2f4"),
        parseHex("5b32ea2e"), parseHex("2d5d1a70"), parseHex("053e613e"), parseHex("5433e39f"),
        parseHex("495529f0"), parseHex("1eaa1aa9"), parseHex("578f572a"), parseHex("698ede71"),
        parseHex("5a0f9dba"), parseHex("398a2e96"), parseHex("0c7b2925"), parseHex("2e6b9564"),
    },
    .{ // Round 6 (final)
        parseHex("026b00de"), parseHex("7644c1e9"), parseHex("5c23d0bd"), parseHex("3470b5ef"),
        parseHex("6013cf3a"), parseHex("48747288"), parseHex("13b7a543"), parseHex("3eaebd44"),
        parseHex("0004e60c"), parseHex("1e8363a2"), parseHex("2343259a"), parseHex("69da0c2a"),
        parseHex("06e3e4c4"), parseHex("1095018e"), parseHex("0deea348"), parseHex("1f4c5513"),
        parseHex("4f9a3a98"), parseHex("3179112b"), parseHex("524abb1f"), parseHex("21615ba2"),
        parseHex("23ab4065"), parseHex("1202a1d1"), parseHex("21d25b83"), parseHex("6ed17c2f"),
    },
    .{ // Round 7 (final)
        parseHex("391e6b09"), parseHex("5e4ed894"), parseHex("6a2f58f2"), parseHex("5d980d70"),
        parseHex("3fa48c5e"), parseHex("1f6366f7"), parseHex("63540f5f"), parseHex("6a8235ed"),
        parseHex("14c12a78"), parseHex("6edde1c9"), parseHex("58ce1c22"), parseHex("718588bb"),
        parseHex("334313ad"), parseHex("7478dbc7"), parseHex("647ad52f"), parseHex("39e82049"),
        parseHex("6fee146a"), parseHex("082c2f24"), parseHex("1f093015"), parseHex("30173c18"),
        parseHex("53f70c0d"), parseHex("6028ab0c"), parseHex("2f47a1ee"), parseHex("26a6780e"),
    },
};

// Internal round constants from plonky3 KoalaBear width-24 (23 rounds)
const INTERNAL_RCS = [INTERNAL_ROUNDS]u32{
    parseHex("3540bc83"), parseHex("1812b49f"), parseHex("5149c827"), parseHex("631dd925"),
    parseHex("001f2dea"), parseHex("7dc05194"), parseHex("3789672e"), parseHex("7cabf72e"),
    parseHex("242dbe2f"), parseHex("0b07a51d"), parseHex("38653650"), parseHex("50785c4e"),
    parseHex("60e8a7e0"), parseHex("07464338"), parseHex("3482d6e1"), parseHex("08a69f1e"),
    parseHex("3f2aff24"), parseHex("5814c30d"), parseHex("13fecab2"), parseHex("61cb291a"),
    parseHex("68c8226f"), parseHex("5c757eea"), parseHex("289b4e1e"),
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
            886409618,  1327899896, 1902407911, 591953491, 648428576,  1844789031,
            1198336108, 355597330,  1799586834, 59617783,  790334801,  1968791836,
            559272107,  31054313,   1042221543, 474748436, 135686258,  263665994,
            1962340735, 1741539604, 2026927696, 449439011, 1131357108, 50869465,
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
