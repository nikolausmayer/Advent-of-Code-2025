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
    var total_splits: i32 = 0;
    var previous_line: []u8 = "";
    while (line_iterator.next()) |c_line| {
        if (c_line.len == 0) {
            break;
        }
        // Init "previous line" storage on first line, copy first line, and skip
        if (previous_line.len == 0) {
            previous_line = try allocator.alloc(u8, c_line.len);
            @memcpy(previous_line, c_line);
            std.debug.print("{s}\n", .{previous_line});
            continue;
        }

        // Get mutable copy of input line
        const line: []u8 = try allocator.alloc(u8, c_line.len);
        defer allocator.free(line);
        @memcpy(line, c_line);

        // Process line
        for (0..line.len) |x| {
            const a = previous_line[x];
            const b = line[x];
            if (a == '|' and b == '^') {
                // Beam splits
                total_splits += 1;
                if (x > 0) {
                    line[x-1] = '|';
                } 
                if (x < line.len-1) {
                    line[x+1] = '|';
                }
            } else if ((a == '|' or a == 'S') and b == '.') {
                // Beam continues
                line[x] = '|';
            }
        }

        std.debug.print("{s}\n", .{line});
        @memcpy(previous_line, line);
    }
    allocator.free(previous_line);

    std.debug.print("Total tachyon beam splits: {d}\n", .{total_splits});
}

