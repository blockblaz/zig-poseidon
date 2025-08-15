const std = @import("std");

test "babyBear16" {
    std.testing.log_level = .debug;
    _ = @import("instances/babybear16.zig");
}

test "koalaBear16" {
    std.testing.log_level = .debug;
    _ = @import("instances/koalabear16.zig");
}

test "koalaBear24" {
    std.testing.log_level = .debug;
    _ = @import("instances/koalabear24.zig");
}