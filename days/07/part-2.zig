const std = @import("std");

pub fn main() !void {
    // Check args
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Jump through the ol' Zig allocator hoop
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Read input file
    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);

    // Iterate over input lines
    var line_iterator = std.mem.splitAny(u8, input, "\n");
    var previous_line: []u64 = &.{};
    while (line_iterator.next()) |c_line| {
        if (c_line.len == 0) {
            break;
        }
        // Init "previous line" storage on first line, copy first line, and skip
        if (previous_line.len == 0) {
            previous_line = try allocator.alloc(u64, c_line.len);
            for (0..c_line.len) |x| {
                if (c_line[x] == 'S') {
                    previous_line[x] = 1;
                } else {
                    previous_line[x] = 0;
                }
            }
            continue;
        }

        const line: []u64 = try allocator.alloc(u64, c_line.len);
        for (line) |*x| {
            x.* = 0;
        }

        // Process line
        for (0..line.len) |x| {
            const a = c_line[x];
            if (a == '^') {
                // Beam splits
                if (x > 0) {
                    line[x-1] += previous_line[x];
                } 
                if (x < line.len-1) {
                    line[x+1] += previous_line[x];
                }
            } else if (a == '.') {
                // Beam continues
                line[x] += previous_line[x];
            }
        }

        @memcpy(previous_line, line);
        allocator.free(line);
    }
    defer allocator.free(previous_line);

    // Sum up all currently active timelines
    var total_timelines: u64 = 0;
    for (previous_line) |i| {
        total_timelines += i;
    }
    std.debug.print("Total timelines: {d}\n", .{total_timelines});
}

