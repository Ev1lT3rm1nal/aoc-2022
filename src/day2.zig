const std = @import("std");

fn parent_dir() ?[]const u8 {
    const file = @src().file;
    const dir = std.fs.path.dirname(file);
    return dir;
}

const Tables = struct {
    losing: u8,
    winning: u8,
    equals: u8,
};

const TableRules = std.array_hash_map.AutoArrayHashMap(u8, Tables);

pub fn main() !void {
    const name = (comptime parent_dir().?) ++ "/days/day2/input";
    const file = try std.fs.cwd().openFile(name, .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const data = try file.readToEndAlloc(alloc, std.math.maxInt(usize));
    defer alloc.free(data);

    var result_types = TableRules.init(alloc);
    defer result_types.deinit();

    // Rock A-X
    try result_types.put('A', .{
        .losing = 'Z',
        .winning = 'Y',
        .equals = 'X',
    });

    // Paper B-Y
    try result_types.put('B', .{
        .losing = 'X',
        .winning = 'Z',
        .equals = 'Y',
    });

    // Scissors C-Z
    try result_types.put('C', .{
        .losing = 'Y',
        .winning = 'X',
        .equals = 'Z',
    });

    var score: isize = 0;

    var score2: isize = 0;

    var plays = std.mem.tokenizeAny(u8, data, "\r\n");

    while (plays.next()) |play| {
        const elve = play[0];
        const column_2 = play[2];

        const result = result_types.get(elve).?;

        score += value(column_2);

        if (column_2 == result.equals) {
            score += 3;
        } else if (column_2 == result.winning) {
            score += 6;
        }

        const result2 = result_types.get(elve).?;

        switch (column_2) {
            'X' => {
                score2 += value(result2.losing);
            },
            'Y' => {
                score2 += value(result2.equals) + 3;
            },
            'Z' => {
                score2 += value(result2.winning) + 6;
            },
            else => unreachable,
        }
    }

    std.debug.print("Final Score {d}\n", .{score});
    std.debug.print("Final Score with 2nd strategy {d}\n", .{score2});
}

fn value(play: u8) isize {
    return switch (play) {
        'X' => 1,
        'Y' => 2,
        'Z' => 3,
        else => unreachable,
    };
}
