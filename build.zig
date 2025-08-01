const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const poseidon_module = b.addModule("poseidon", .{
        .root_source_file = b.path("src/poseidon2/poseidon2.zig"),
    });

    const babybear_module = b.addModule("poseidon-babybear", .{
        .root_source_file = b.path("src/instances/babybear16.zig"),
        .imports = &.{
            .{ .name = "poseidon", .module = poseidon_module },
        },
    });

    const lib = b.addStaticLibrary(.{
        .name = "zig-poseidon",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("poseidon", poseidon_module);
    lib.root_module.addImport("poseidon-babybear", babybear_module);
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    run_main_tests.has_side_effects = true;

    const bench_exe = b.addExecutable(.{
        .name = "bench",
        .root_source_file = .{ .cwd_relative = "src/bench.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_bench = b.addRunArtifact(bench_exe);

    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&run_bench.step);
    
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
