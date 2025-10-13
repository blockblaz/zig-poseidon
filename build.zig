const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Generic Poseidon2 module
    _ = b.addModule("poseidon2", .{
        .root_source_file = b.path("src/poseidon2/poseidon2.zig"),
    });

    // BabyBear16 instance
    _ = b.addModule("babybear16", .{
        .root_source_file = b.path("src/instances/babybear16.zig"),
    });

    // KoalaBear16 instance (compatible with Rust hash-sig)
    _ = b.addModule("koalabear16", .{
        .root_source_file = b.path("src/instances/koalabear16.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "zig-poseidon",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    run_main_tests.has_side_effects = true;

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
