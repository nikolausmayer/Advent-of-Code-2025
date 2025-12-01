
const std = @import("std");

pub fn main() !void 
{
    // Check argv length
    if (std.os.argv.len != 2) {
        return error{badArgs}.badArgs;
    }
    // or
    std.debug.assert(std.os.argv.len == 2);

    // Open input file
    const t_file = try std.fs.cwd().openFile(std.mem.span(std.os.argv[1]), .{.mode = .read_only});
    defer t_file.close();

    // Storage for input
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var as_input = try std.ArrayList([]const u8).initCapacity(allocator, 1024);
    defer as_input.deinit(allocator);
    defer for (as_input.items) |i| { allocator.free(i); };

    // Read input
    var a16u8_reader_buffer: [16]u8 = undefined;
    // This must be var and cannot be folded into "p_reader = t_file.reader(..).interface"
    var file_reader = t_file.reader(&a16u8_reader_buffer);
    // This should be a const ptr, not copy the interface
    const p_reader = &file_reader.interface;
    // Loop over lines
    while (p_reader.takeDelimiterExclusive('\n')) |line| {
        // Use line data
        //std.debug.print("{s}\n", .{line});

        // Make an explicitly allocated copy of the input line, and shove that
        // into the list.
        // The ArrayList stores pointers, so copying the input line directly
        // just loses the original data immediately. This WILL result in the
        // list being random garbage.
        // Note how this is a const-value of non-const-slice type, because
        // we need to memcpy into it.
        const linebuffer: []u8 = try allocator.alloc(u8, line.len);
        @memcpy(linebuffer, line);
        try as_input.append(allocator, linebuffer);

        //try as_input.append(allocator, line);
        // takeDelimiterExclusive does not remove the delimiter/sentinel, so we do that manually
        _ = try p_reader.takeByte();
    } else |err| switch (err) {
        // EOF is ok
        error.EndOfStream => {},
        error.StreamTooLong, error.ReadFailed => return err,
    }

    // Process input
    //for (0..as_input.items.len) |i| {
    //    const p_line: *[]const u8 = &as_input.items[i];
    //    std.debug.print(">>{d} {s} {*s}\n", .{i, p_line.*, p_line});
    //}
    var i32_dial_points_at: i32 = 50;
    var i32_total_zeros: i32 = 0;
    for (as_input.items) |*i| {
        //std.debug.print(">>{s}\n", .{i.*});
        const uz_clicks: usize = try std.fmt.parseInt(usize, i.*[1..], 10);
        switch (i.*[0]) {
            'L' => {
                for (0..uz_clicks) |_| {
                    i32_dial_points_at = @mod(i32_dial_points_at - 1, 100);
                    if (i32_dial_points_at == 0) {
                        i32_total_zeros += 1;
                    }
                }
            },
            'R' => {
                for (0..uz_clicks) |_| {
                    i32_dial_points_at = @mod(i32_dial_points_at + 1, 100);
                    if (i32_dial_points_at == 0) {
                        i32_total_zeros += 1;
                    }
                }
            },
            else => unreachable,
        }

    }

    std.debug.print("result: pointed at 0 a total of {d} times\n", .{i32_total_zeros});
}

