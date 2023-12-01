const std = @import("std");

fn parent_dir() ?[]const u8 {
    const file = @src().file;
    const dir = std.fs.path.dirname(file);
    return dir;
}

pub fn main() !void {
    const name = (comptime parent_dir().?) ++ "/days/day1/input";
    const file = try std.fs.cwd().openFile(name, .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const data = try file.readToEndAlloc(alloc, std.math.maxInt(usize));
    defer alloc.free(data);

    var top_elves = std.ArrayList(isize).init(alloc);
    var elves = std.mem.tokenizeSequence(u8, data, "\n\n");
    while (elves.next()) |elve| {
        var current_calories: isize = 0;
        var all_food = std.mem.tokenizeAny(u8, elve, "\r\n");
        while (all_food.next()) |food| {
            current_calories += try std.fmt.parseInt(isize, food, 10);
        }
        try top_elves.append(current_calories);
    }

    const top_food = try top_elves.toOwnedSlice();
    defer alloc.free(top_food);
    std.sort.block(isize, top_food, {}, std.sort.desc(isize));

    var top_3: isize = 0;

    for (top_food[0..3]) |elve| {
        top_3 += elve;
    }

    std.debug.print("Elve with most calories is {d}\n", .{top_food[0]});

    std.debug.print("Top three elves with most calories {d}\n", .{top_3});
}
