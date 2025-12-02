const std = @import("std");

pub fn main() !void {
    // Time for a buffered stdout printer..
    var a256u8_stdout_buf: [256]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&a256u8_stdout_buf);
    const p_stdout = &stdout_writer.interface;

    // Check argv length
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Get an allocator (and defer its own deallocation?)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open input file
    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);
    // var file_handle = try std.fs.cwd().openFileZ(std.os.argv[1], .{.mode = .read_only});
    // defer file_handle.close();
    // // This time the input is a single line, so no loop
    // var a16u8_reader_buffer: [1024]u8 = undefined;
    // var input = file_handle.reader(&a16u8_reader_buffer);
    // const line = try input.interface.takeDelimiterExclusive('\n');

    try p_stdout.print("input: <<<{s}>>>\n", .{input});

    var u64_sum_of_invalid_ids: u64 = 0;

    var pair_iterator = std.mem.splitAny(u8, input, ",\n");
    while (pair_iterator.next()) |s_product_id_range| {
        if (s_product_id_range.len == 0) {
            break;
        }
        try p_stdout.print("<{s}>\n", .{s_product_id_range});
        var number_iterator = std.mem.tokenizeScalar(u8, s_product_id_range, '-');
        const u64_first_id = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
        const u64_last_id  = try std.fmt.parseInt(u64, number_iterator.next().?, 10);
        try p_stdout.print("-> {d} - {d}\n", .{u64_first_id, u64_last_id});

        var a64u8_print_buf: [64]u8 = undefined;
        for (u64_first_id..u64_last_id+1) |u64_id| {
            const s_id = try std.fmt.bufPrint(&a64u8_print_buf, "{}", .{u64_id});
            try p_stdout.print("  {s}\n", .{s_id});
            if (s_id.len % 2 == 1) {
                continue;
            }
            try p_stdout.print("  --{s} {s}\n", .{s_id[0..s_id.len/2], s_id[s_id.len/2..]});
            if (std.mem.eql(u8, s_id[0..s_id.len/2], s_id[s_id.len/2..])) {
                try p_stdout.print("  --invalid--\n", .{});
                u64_sum_of_invalid_ids += u64_id;
            }
            try p_stdout.flush();
        }
    }

    try p_stdout.print("sum of invalid IDs is {d}\n", .{u64_sum_of_invalid_ids});
    try p_stdout.flush();
}
