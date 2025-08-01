const std = @import("std");
const Poseidon2BabyBear = @import("instances/babybear16.zig").Poseidon2BabyBear;
const WIDTH = 16;

fn testPermutation(state: [WIDTH]u32) [WIDTH]u32 {
    const F = Poseidon2BabyBear.Field;
    var mont_state: [WIDTH]F.MontFieldElem = undefined;
    inline for (0..WIDTH) |j| {
        F.toMontgomery(&mont_state[j], state[j]);
    }
    Poseidon2BabyBear.permutation(&mont_state);
    var ret: [WIDTH]u32 = undefined;
    inline for (0..WIDTH) |j| {
        ret[j] = F.toNormal(mont_state[j]);
    }
    return ret;
}

fn sched_setaffinity(pid: std.os.linux.pid_t, set: *const std.os.linux.cpu_set_t) !void {
    const size = @sizeOf(std.os.linux.cpu_set_t);
    const rc = std.os.linux.syscall3(.sched_setaffinity, @as(usize, @bitCast(@as(isize, pid))), size, @intFromPtr(set));
    switch (std.posix.errno(rc)) {
        .SUCCESS => return,
        else => |err| return std.posix.unexpectedErrno(err),
    }
}
pub fn main() !void {
    const cpu0001: std.os.linux.cpu_set_t = [1]usize{0b0001} ++ ([_]usize{0} ** (16 - 1));
    try sched_setaffinity(0, &cpu0001);

    const stdout = std.io.getStdOut().writer();
    const iterations_list = [_]usize{ 100, 1_000, 10_000, 100_000, 1_000_000 };

    var rand = std.Random.DefaultPrng.init(42);

    for (iterations_list) |iterations| {
        std.debug.print("\n=== Starting Poseidon2 BabyBear benchmark ({d} iterations) ===\n", .{iterations});

        var input_state: [WIDTH]u32 = undefined;
        for (0..WIDTH) |i| {
            input_state[i] = @truncate(rand.next());
        }

        _ = testPermutation(input_state);

        // Start timing
        const start = std.time.nanoTimestamp();
        var final_state: [WIDTH]u32 = undefined;

        // Benchmark loop
        for (0..iterations) |i| {
            if (iterations >= 100_000 and i > 0 and i % 250_000 == 0) {
                std.debug.print("Progress: {d}/{d} iterations\n", .{ i, iterations });
            }

            // Randomize input state
            for (0..WIDTH) |j| {
                input_state[j] = @truncate(rand.next());
            }

            final_state = testPermutation(input_state);
        }


        const end = std.time.nanoTimestamp();
        const elapsed_ns = end - start;
        const avg_time_ns = @divTrunc(elapsed_ns, @as(i128, iterations));

        try stdout.print("Total time for {d} iterations: {d} ns ({d:.2} seconds)\n", .{ iterations, elapsed_ns, @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000 });
        try stdout.print("Average time per hash: {d} ns\n", .{avg_time_ns});
        try stdout.print("Hashes per second: {d:.2}\n", .{@as(f64, 1_000_000_000) / @as(f64, @floatFromInt(avg_time_ns))});

        // ensure the compiler doesn't optimize away the computation
        std.debug.print("Final state[0] = {d} (verification value)\n", .{final_state[0]});
    }

    std.debug.print("\nAll benchmarks completed successfully\n", .{});
}
