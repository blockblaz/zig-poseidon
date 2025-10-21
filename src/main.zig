const std = @import("std");

test "BabyBear16" {
    std.testing.log_level = .debug;
    _ = @import("instances/babybear16.zig");
}

test "KoalaBear16" {
    std.testing.log_level = .debug;
    _ = @import("instances/koalabear16_generic.zig");
}
