const std = @import("std");

pub fn main() !void {
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Get an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Read puzzle input
    const s_input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(s_input);

    // Parse input
    // We'll store the fresh ingredient ID ranges, then process the available
    // ingredient IDs in-place.
    var aa2u64_fresh_ranges = try std.ArrayList([2]u64).initCapacity(allocator, 1_024);
    defer aa2u64_fresh_ranges.deinit(allocator);
    //defer for (aa2u64_fresh_ranges.items) |i| { allocator.free(i); };
    var line_iterator = std.mem.splitAny(u8, s_input, "\n");
    var state: i32 = 0;
    var i32_fresh_ingredients_count: i32 = 0;
    while (line_iterator.next()) |s_line| {
        if (s_line.len == 0) {
            if (state == 0) {
                state = 1;
                continue;
            } else {
                break;
            }
        }
        if (state == 0) {
            var number_iterator = std.mem.splitAny(u8, s_line, "-");
            const u64_a = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
            const u64_b = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
            try aa2u64_fresh_ranges.append(allocator, .{u64_a, u64_b});
            //std.debug.print(">{d} - {d}\n", .{u64_a, u64_b});
        } else {
            const u64_ingredient_id = try std.fmt.parseInt(u64, s_line, 10);
            //std.debug.print(">>{d}\n", .{u64_ingredient_id});
            for (aa2u64_fresh_ranges.items) |a2u64_range| {
                if (u64_ingredient_id >= a2u64_range[0] and
                    u64_ingredient_id <= a2u64_range[1]) {
                    i32_fresh_ingredients_count += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("Fresh available ingredient IDs: {d}\n", .{i32_fresh_ingredients_count});
}

