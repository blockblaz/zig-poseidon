const std = @import("std");
const assert = std.debug.assert;

pub fn Poseidon2(
    comptime F: type,
    comptime width: comptime_int,
    comptime int_rounds: comptime_int,
    comptime ext_rounds: comptime_int,
    comptime sbox_degree: comptime_int,
    internal_diagonal: [width]u32,
    external_rcs: [ext_rounds][width]u32,
    internal_rcs: [int_rounds]u32,
) type {
    comptime var ext_rcs: [ext_rounds][width]F.MontFieldElem = undefined;
    for (0..ext_rounds) |i| {
        for (0..width) |j| {
            F.toMontgomery(&ext_rcs[i][j], external_rcs[i][j]);
        }
    }
    comptime var int_rcs: [int_rounds]F.MontFieldElem = undefined;
    for (0..int_rounds) |i| {
        F.toMontgomery(&int_rcs[i], internal_rcs[i]);
    }
    comptime var int_diagonal: [width]F.MontFieldElem = undefined;
    for (0..width) |i| {
        F.toMontgomery(&int_diagonal[i], internal_diagonal[i]);
    }
    return struct {
        pub const Field = F;
        pub const State = [width]F.MontFieldElem;

        pub fn compress(comptime output_len: comptime_int, input: [width]F.FieldElem) [output_len]F.FieldElem {
            assert(output_len <= width);

            var state: State = undefined;
            inline for (0..width) |i| {
                F.toMontgomery(&state[i], input[i]);
            }
            permutation(&state);
            inline for (0..width) |i| {
                var input_mont: F.MontFieldElem = undefined;
                F.toMontgomery(&input_mont, input[i]);
                F.add(&state[i], state[i], input_mont);
            }

            var result: [output_len]F.FieldElem = undefined;
            inline for (0..output_len) |i| {
                result[i] = F.toNormal(state[i]);
            }
            return result;
        }

        pub fn permutation(state: *State) void {
            mulExternal(state);
            inline for (0..ext_rounds / 2) |r| {
                addRCs(state, r);
                inline for (0..width) |i| {
                    state[i] = sbox(state[i]);
                }
                mulExternal(state);
            }

            const start = ext_rounds / 2;
            const end = start + int_rounds;
            for (start..end) |r| {
                F.add(&state[0], state[0], int_rcs[r - start]);
                state[0] = sbox(state[0]);
                mulInternal(state);
            }

            inline for (end..end + ext_rounds / 2) |r| {
                addRCs(state, r - int_rounds);
                inline for (0..width) |i| {
                    state[i] = sbox(state[i]);
                }
                mulExternal(state);
            }
        }

        inline fn mulExternal(state: *State) void {
            if (width < 3) {
                @compileError("only widths >= 3 are supported");
            }
            // Support widths 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, etc.
            if (width >= 8 and width % 4 != 0) {
                @compileError("for widths >= 8, only widths multiple of 4 are supported");
            }

            // FIXED: Use proper circulant MDS matrix multiplication
            // The MDS matrix is circulant, so we need to use circulant indexing
            var new_state: State = undefined;

            for (0..width) |i| {
                var sum: F.MontFieldElem = undefined;
                F.toMontgomery(&sum, 0); // Initialize to zero

                for (0..width) |j| {
                    const diag_idx = (width + j - i) % width; // Circulant indexing
                    var temp: F.MontFieldElem = undefined;
                    F.mul(&temp, state[j], int_diagonal[diag_idx]);
                    F.add(&sum, sum, temp);
                }
                new_state[i] = sum;
            }

            // Copy the result back to state
            for (0..width) |i| {
                state[i] = new_state[i];
            }
        }

        // mulM4 calculates 'M4*state' in a way we can later can calculate
        // circ(2*M4, M4, ...)*state from it.
        inline fn mulM4(input: *State) void {
            // Use HorizenLabs minimal multiplication algorithm to perform
            // the least amount of operations for it. Similar to an
            // addition/multiplication chain.
            const t4 = width / 4;
            inline for (0..t4) |i| {
                const start_index = i * 4;
                var t_0: F.MontFieldElem = undefined;
                F.add(&t_0, input[start_index], input[start_index + 1]);
                var t_1: F.MontFieldElem = undefined;
                F.add(&t_1, input[start_index + 2], input[start_index + 3]);
                var t_2: F.MontFieldElem = undefined;
                F.add(&t_2, input[start_index + 1], input[start_index + 1]);
                F.add(&t_2, t_2, t_1);
                var t_3: F.MontFieldElem = undefined;
                F.add(&t_3, input[start_index + 3], input[start_index + 3]);
                F.add(&t_3, t_3, t_0);
                var t_4 = t_1;
                F.add(&t_4, t_4, t_4);
                F.add(&t_4, t_4, t_4);
                F.add(&t_4, t_4, t_3);
                var t_5 = t_0;
                F.add(&t_5, t_5, t_5);
                F.add(&t_5, t_5, t_5);
                F.add(&t_5, t_5, t_2);
                var t_6 = t_3;
                F.add(&t_6, t_6, t_5);
                var t_7 = t_2;
                F.add(&t_7, t_7, t_4);
                input[start_index] = t_6;
                input[start_index + 1] = t_5;
                input[start_index + 2] = t_7;
                input[start_index + 3] = t_4;
            }
        }

        inline fn mulInternal(state: *State) void {
            // Match plonky3's generic_internal_linear_layer implementation
            // Calculate part_sum = sum of state[1..] (excluding state[0])
            var part_sum = state[1];
            inline for (2..width) |i| {
                F.add(&part_sum, part_sum, state[i]);
            }

            // Calculate full_sum = part_sum + state[0]
            var full_sum = part_sum;
            F.add(&full_sum, full_sum, state[0]);

            // Special handling for state[0]: state[0] = part_sum - state[0]
            // Compute negation in normal form: -x = P - x (where P is the modulus)
            const state_0_normal = F.toNormal(state[0]);
            const neg_state_0_normal = F.MODULUS - state_0_normal;
            var neg_state_0: F.MontFieldElem = undefined;
            F.toMontgomery(&neg_state_0, neg_state_0_normal);
            var new_state_0 = part_sum;
            F.add(&new_state_0, new_state_0, neg_state_0);

            // Apply diagonal to state[0] first
            F.mul(&state[0], new_state_0, int_diagonal[0]);
            F.add(&state[0], state[0], full_sum);

            // Apply diagonal to state[1..] (as per plonky3's internal_layer_mat_mul)
            inline for (1..width) |i| {
                F.mul(&state[i], state[i], int_diagonal[i]);
                F.add(&state[i], state[i], full_sum);
            }
        }

        inline fn sbox(e: F.MontFieldElem) F.MontFieldElem {
            return switch (sbox_degree) {
                3 => blk: {
                    // x^3 = x * x * x = (x^2) * x
                    var e_squared: F.MontFieldElem = undefined;
                    F.square(&e_squared, e);
                    var res: F.MontFieldElem = undefined;
                    F.mul(&res, e_squared, e);
                    break :blk res;
                },
                7 => blk: {
                    // x^7 = x^4 * x^2 * x
                    var e_squared: F.MontFieldElem = undefined;
                    F.square(&e_squared, e);
                    var e_forth: F.MontFieldElem = undefined;
                    F.square(&e_forth, e_squared);
                    var res: F.MontFieldElem = undefined;
                    F.mul(&res, e_forth, e_squared);
                    F.mul(&res, res, e);
                    break :blk res;
                },
                else => @compileError("sbox degree not supported"),
            };
        }

        inline fn addRCs(state: *State, round: u8) void {
            inline for (0..width) |i| {
                F.add(&state[i], state[i], ext_rcs[round][i]);
            }
        }
    };
}
