const std = @import("std");

pub fn main() !void {
    // Check input arguments
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Read input
    const s_input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(s_input);
    // Split into lines
    var line_iterator = std.mem.splitAny(u8, s_input, "\n");
    // Collect lines
    var map = try std.ArrayList([]u8).initCapacity(allocator, 1024);
    defer map.deinit(allocator);
    defer for (map.items) |i| { allocator.free(i); };
    while (line_iterator.next()) |s_line| {
        if (s_line.len == 0) {
            break;
        }
        const buf = try allocator.alloc(u8, s_line.len);
        @memcpy(buf, s_line);
        try map.append(allocator, buf);
    }

    const H = map.items.len;
    const W = map.items[0].len;
    var i32_total_removed_rolls: i32 = 0;
    while (true) {
        // Iterate map
        var i32_accessible_rolls: i32 = 0;
        for (0..H) |my| {
            //std.debug.print("{s}\n", .{map.items[my]});
            for (0..W) |mx| {
                if (map.items[my][mx] != '@') {
                    continue;
                }
                var i32_occupied_fields: i32 = 0;
                // Iterate block around item
                var dy: i32 = -1;
                //std.debug.print("{c}", .{map.items[my][mx]});
                while (dy <= 1) : (dy += 1) {
                    var dx: i32 = -1;
                    while (dx <= 1) : (dx += 1) {
                        if (dx == 0 and dy == 0) {
                            continue;
                        }
                        const y = @as(i32, @intCast(my)) + dy;
                        const x = @as(i32, @intCast(mx)) + dx;
                        if (x < 0 or x >= W or y < 0 or y >= H) {
                            continue;
                        }
                        //std.debug.print("-{c}-", .{map.items[@intCast(y)][@intCast(x)]});
                        if (map.items[@intCast(y)][@intCast(x)] == '@') {
                            i32_occupied_fields += 1;
                        }
                    }
                }
                //std.debug.print("\n", .{});
                if (i32_occupied_fields < 4) {
                    i32_accessible_rolls += 1;
                    map.items[my][mx] = '.';
                }
            }
        }
        std.debug.print("Accessible rolls: {d}\n", .{i32_accessible_rolls});
        if (i32_accessible_rolls == 0) {
            break;
        } else {
            i32_total_removed_rolls += i32_accessible_rolls;
        }
    }

    std.debug.print("Total removed rolls: {d}\n", .{i32_total_removed_rolls});
}

