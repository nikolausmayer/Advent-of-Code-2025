const std = @import("std");

// Store a range bound, either opening or closing
const Entry = struct{
    u64_n: u64,
    o_is_start: bool,

    // Custom sorting function, keyed by ID
    fn lessThan(ctx: void, a: Entry, b: Entry) bool {
        _ = ctx;
        // Sorting range openings before range closings makes the counting
        // logic in the end much easier, because there are no special cases
        // with overlapping ranges.
        return a.u64_n < b.u64_n or 
               ((a.u64_n == b.u64_n) and a.o_is_start and !b.o_is_start);
    }
};

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
    var at_range_bounds = try std.ArrayList(Entry).initCapacity(allocator, 1_024);
    defer at_range_bounds.deinit(allocator);
    {
        var line_iterator = std.mem.splitAny(u8, s_input, "\n");
        while (line_iterator.next()) |s_line| {
            if (s_line.len == 0) {
                break;
            }
            var number_iterator = std.mem.splitAny(u8, s_line, "-");
            const u64_a = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
            const u64_b = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
            try at_range_bounds.append(allocator, .{.u64_n = u64_a, .o_is_start = true });
            try at_range_bounds.append(allocator, .{.u64_n = u64_b, .o_is_start = false});
        }
    }
    // Sort list
    std.mem.sort(Entry, at_range_bounds.items, {}, Entry.lessThan);
    // Now iterate over all range bounds. When an opening is found, the count
    // of currently open ranges is incremented, else it is decremented.
    // When an opening is found with no currently open ranges, it is stored.
    // When a closing is found that closes the last open range, the range from
    // the last stored opening to this closing is a "fresh" range.
    var u32_open_ranges: u32 = 0;
    var u64_fresh_ids_count: u64 = 0;
    var u64_last_opening: u64 = undefined;
    for (at_range_bounds.items) |entry| {
        if (entry.o_is_start) {
            if (u32_open_ranges == 0) {
                u64_last_opening = entry.u64_n;
            }
            u32_open_ranges += 1;
        } else {
            u32_open_ranges -= 1;
            if (u32_open_ranges == 0) {
                u64_fresh_ids_count += (entry.u64_n - u64_last_opening + 1);
            }
        }
    }

    std.debug.print("Fresh ingredient IDs: {d}\n", .{u64_fresh_ids_count});
}

