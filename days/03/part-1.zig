const std = @import("std");

pub fn main() !void {
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);

    var u32_sum_of_max_joltages: u32 = 0;
    var banks_iterator = std.mem.splitAny(u8, input, "\n");
    while (banks_iterator.next()) |bank| {
        if (bank.len == 0) {
            break;
        }
        std.debug.print("<{s}>\n", .{bank});
        var u8_bank_max_joltage: u8 = 0;
        for (0..bank.len-1) |i| {
            for (i+1..bank.len) |j| {
                u8_bank_max_joltage = @max(u8_bank_max_joltage,
                    (bank[i] - '0') * 10 +
                    (bank[j] - '0'));
            }
        }
        std.debug.print("max bank joltage is {d}\n", .{u8_bank_max_joltage});
        u32_sum_of_max_joltages += u8_bank_max_joltage;
    }

    std.debug.print("total output joltage is {d}\n", .{u32_sum_of_max_joltages});
}

