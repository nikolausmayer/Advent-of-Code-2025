const std = @import("std");

const tuple_length = 4;

var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
//defer _ = gpa.deinit();
const allocator = gpa.allocator();

pub fn main() !void {
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);

    var tuples = try std.ArrayList([tuple_length]u64).initCapacity(allocator, 1_024);
    defer tuples.deinit(allocator);
    
    var line_iterator = std.mem.splitAny(u8, input, "\n");
    var iteration: usize = 0;
    var grand_total: u64 = 0;
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        //std.debug.print("{d} | {s}\n", .{iteration, line});
        var item_iterator = std.mem.splitAny(u8, line, " ");
        var idx: usize = 0;
        while (item_iterator.next()) |item| {
            if (item.len == 0) {
                continue;
            }
            if (iteration == 0) {
                try tuples.append(allocator, .{try std.fmt.parseInt(u64, item, 10), 0, 0, 0});
            } else if (iteration == tuple_length) {
                const t = &tuples.items[idx];
                if (std.mem.eql(u8, item, "+")) {
                    grand_total += t[0] + t[1] + t[2] + t[3];
                } else {
                    grand_total += t[0] * t[1] * t[2] * t[3];
                }
            } else {
                tuples.items[idx][iteration] = try std.fmt.parseInt(u64, item, 10);
            }
            idx += 1;
        }
        iteration += 1;
    }

    std.debug.print("Grand total is {d}\n", .{grand_total});
}

