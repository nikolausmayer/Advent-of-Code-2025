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

    var u64_sum_of_max_joltages: u64 = 0;
    var banks_iterator = std.mem.splitAny(u8, input, "\n");
    while (banks_iterator.next()) |bank| {
        if (bank.len == 0) {
            break;
        }
        //std.debug.print("<{s}>\n", .{bank});
        var u64_bank_max_joltage: u64 = 0;
        var uz_next_digit_starts_at: usize = 0;
        for (0..12) |digit_pos| {
            var u8_largest_available_digit: u8 = '0';
            var uz_largest_available_digit_position: usize = 0;
            for (uz_next_digit_starts_at..bank.len - (12 - digit_pos - 1)) |i| {
                if (bank[i] > u8_largest_available_digit) {
                    u8_largest_available_digit = bank[i];
                    uz_largest_available_digit_position = i;
                }
            }
            u64_bank_max_joltage += (u8_largest_available_digit - '0') * try std.math.powi(u64, 10, 11-digit_pos);
            uz_next_digit_starts_at = uz_largest_available_digit_position + 1;
        }
        //std.debug.print("max bank joltage is {d}\n", .{u64_bank_max_joltage});
        u64_sum_of_max_joltages += u64_bank_max_joltage;
    }

    std.debug.print("total output joltage is {d}\n", .{u64_sum_of_max_joltages});
}

