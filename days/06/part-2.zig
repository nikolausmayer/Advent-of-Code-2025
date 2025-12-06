const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
//defer _ = gpa.deinit();
const allocator = gpa.allocator();

pub fn main() !void {
    // Check arguments
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Read input file
    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);

    // Allocate space for indexable map
    var map = try std.ArrayList([]u8).initCapacity(allocator, 1_024);
    defer map.deinit(allocator);
    defer for (map.items) |i| { allocator.free(i); };

    // Copy input lines into map
    {
        var line_iterator = std.mem.splitAny(u8, input, "\n");
        while (line_iterator.next()) |line| {
            if (line.len == 0) {
                break;
            }
            const buffer = try allocator.alloc(u8, line.len);
            @memcpy(buffer, line);
            try map.append(allocator, buffer);
        }
    }

    const H = map.items.len;
    const W = map.items[0].len;

    var u64_grand_total: u64 = 0;
    var u64_block_result: u64 = 0;
    var operation: u8 = undefined;
    for (0..W) |x| {
        {
            var new_block = true;
            for (0..H) |y| {
                if (map.items[y][x] != ' ') {
                    new_block = false;
                    break;
                }
            }
            if (new_block) {
                //std.debug.print("new block\n", .{});
                u64_grand_total += u64_block_result;
                continue;
            }
        }
        if (map.items[H-1][x] != ' ') {
            operation = map.items[H-1][x];
            if (operation == '*') {
                u64_block_result = 1;
            } else {
                u64_block_result = 0;
            }
        }
        var u64_number: u64 = 0;
        for (0..H-1) |y| {
            const digit = map.items[y][x];
            if (digit != ' ') {
                u64_number = u64_number * 10 + (digit - '0');
            }
        }
        if (operation == '*') {
            u64_block_result *= u64_number;
        } else {
            u64_block_result += u64_number;
        }
        //std.debug.print("{d} block total now {d}\n", .{u64_number, u64_block_result});
    }
    // Don't forget the final block!
    u64_grand_total += u64_block_result;

    std.debug.print("Grand total is {d}\n", .{u64_grand_total});
}

