const std = @import("std");

const days = blk: {
    var list: [25][]const u8 = undefined;
    var buff: [2]u8 = undefined;
    for (1..26) |day| {
        const size = std.fmt.formatIntBuf(&buff, day, 10, .lower, .{});
        list[day - 1] = "src/day" ++ buff[0..size] ++ ".zig";
    }

    break :blk list;
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const day = b.option(u8, "day", "The day you want to compile");
    const all = b.option(bool, "all", "[default] selects if you wanna compile all days") orelse (day == null);

    if (day == null and all == false) {
        @panic("Nothing to build was selected");
    }

    if (day) |selected| {
        if (!(selected > 0 and selected <= 25)) {
            @panic("Selected day is invalid. It mus be between 1 and 25");
        }
    }

    var list_exe = try std.ArrayList(*std.Build.CompileStep).initCapacity(b.allocator, 25);
    defer list_exe.deinit();
    var list_run = try std.ArrayList(*std.Build.Step.Run).initCapacity(b.allocator, 25);
    defer list_run.deinit();

    if (day) |selected| {
        try list_exe.append(dayToExe(b, selected, target, optimize));
    } else {
        for (0..26) |day_i| {
            try list_exe.append(dayToExe(b, day_i, target, optimize));
        }
    }

    for (list_exe.items) |exe| {
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        try list_run.append(run_cmd);
        run_cmd.step.dependOn(b.getInstallStep());
    }

    const run_step = b.step("run", "Run apps");
    for (list_run.items) |run_cmd| {
        run_step.dependOn(&run_cmd.step);
    }
}

fn dayToExe(b: *std.Build, day: usize, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode) *std.Build.CompileStep {
    const name = days[day - 1];
    return b.addExecutable(.{
        .name = name[4 .. name.len - 5],
        .root_source_file = .{ .path = name },
        .target = target,
        .optimize = optimize,
    });
}
