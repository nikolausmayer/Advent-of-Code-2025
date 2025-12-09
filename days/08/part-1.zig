const std = @import("std");

// A "x,y,z" junction box location
const Point = struct {
    x: i64, 
    y: i64, 
    z: i64,

    pub fn distance(self: *const Point, other: *const Point) i64 {
        return (self.x - other.x) * (self.x - other.x) +
               (self.y - other.y) * (self.y - other.y) +
               (self.z - other.z) * (self.z - other.z);
    }

    pub fn lessThan(self: *const Point, other: *const Point) bool {
        if (self.x < other.x) return true;
        if (self.x > other.x) return false;
        if (self.y < other.y) return true;
        if (self.y > other.y) return false;
        if (self.z < other.z) return true;
        if (self.z > other.z) return false;
        return true;
    }
};

// A potential link between 2 junction boxes, along with its distance
const Pair = struct {
    from: *const Point, 
    to: *const Point, 
    distance: i64,

    fn lessThan(ctx: void, a: Pair, b: Pair) bool {
        _ = ctx;
        return a.distance < b.distance;
    }
};

const UnionFind = struct {
    parent: std.hash_map.AutoHashMap(Item, Item),

    const Item  = *const Point;
    const Self  = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .parent = .init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.parent.deinit();
    }

    pub fn insert(self: *Self, item: Item) !void {
        try self.parent.put(item, item);
    }

    pub fn find(self: *Self, item: Item) !Item {
        while (self.parent.get(item).? != self.parent.get(self.parent.get(item).?).?) {
            try self.parent.put(item, try self.find(self.parent.get(item).?));
        }
        return self.parent.get(item).?;
    }

    pub fn join(self: *Self, a: Item, b: Item) !void {
        const pa = try self.find(a);
        const pb = try self.find(b);
        if (pa.lessThan(pb)) {
            try self.parent.put(pa, pb);
        } else {
            try self.parent.put(pb, pa);
        }
    }
};

pub fn main() !void {
    // Check args
    if (std.os.argv.len != 2) {
        return error.badArgs;
    }

    // Get allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Read input
    const input = try std.fs.cwd().readFileAlloc(allocator, std.mem.span(std.os.argv[1]), 65_535);
    defer allocator.free(input);

    var all_points = try std.ArrayList(Point).initCapacity(allocator, 1_000);
    defer all_points.deinit(allocator);

    var all_pairs = try std.ArrayList(Pair).initCapacity(allocator, 500_000);
    defer all_pairs.deinit(allocator);

    // Parse input
    var ordinate_iterator = std.mem.splitAny(u8, input, ",\n");
    while (true) {
        // parseInt below fails on an empty string, with an error I cannot 
        // manage to catch... so let's do it proper
        if (ordinate_iterator.peek().?.len == 0) {
            break;
        }
        try all_points.append(allocator, .{
            .x = try std.fmt.parseInt(i64, ordinate_iterator.next().?, 10),
            .y = try std.fmt.parseInt(i64, ordinate_iterator.next().?, 10),
            .z = try std.fmt.parseInt(i64, ordinate_iterator.next().?, 10),
        });
    }

    // Generate pairs
    for (0..all_points.items.len-1) |i| {
        for (i+1..all_points.items.len) |j| {
            try all_pairs.append(allocator, .{
                .from = &all_points.items[i],
                .to   = &all_points.items[j],
                .distance = all_points.items[i].distance(&all_points.items[j]),
            });
        }
    }
     
    // Sort pairs by distance
    std.mem.sort(Pair, all_pairs.items, {}, Pair.lessThan);

    // Union-find: fuse all applicable pairs
    var uf = UnionFind.init(allocator);
    defer uf.deinit();
    for (all_points.items) |*point| {
        try uf.insert(point);
    }
    {
        var connections_made: usize = 0;
        var idx: usize = 0;
        while (connections_made < 1_000) {
            if (idx >= all_pairs.items.len) {
                return error.badIndex;
            }
            const a = all_pairs.items[idx].from;
            const b = all_pairs.items[idx].to;
            if (try uf.find(a) != try uf.find(b)) {
                //std.debug.print("{d},{d},{d} -link-> {d},{d},{d}\n", .{a.x, a.y, a.z, b.x, b.y, b.z});
                try uf.join(a, b);
            //} else {
            //    std.debug.print("skip {d},{d},{d} --> {d},{d},{d}\n", .{a.x, a.y, a.z, b.x, b.y, b.z});
            }
            connections_made += 1;
            idx += 1;
        }
    }

    // Now scan union-find data structure's results and collect how many nodes
    // each parent has
    // Map junction boxes to circuit sizes
    var circuit_sizes = std.hash_map.AutoHashMap(*const Point, usize).init(allocator);
    defer circuit_sizes.deinit();
    {
        for (all_points.items) |*point| {
            try circuit_sizes.put(point, 0);
        }
        var vi = uf.parent.keyIterator();
        while (vi.next()) |v| {
            const p = try uf.find(v.*);
            const i = circuit_sizes.get(p).?;
            try circuit_sizes.put(p, i+1);
        }
    }

    var circuit_sizes_list = try std.ArrayList(usize).initCapacity(allocator, all_points.items.len);
    defer circuit_sizes_list.deinit(allocator);
    {
        var vi = circuit_sizes.valueIterator();
        while (vi.next()) |v| {
            try circuit_sizes_list.append(allocator, v.*);
        }
        std.mem.sort(usize, circuit_sizes_list.items, {}, comptime std.sort.desc(usize));
    }

    var result: usize = 1;
    for (0..3) |i| {
        //std.debug.print("{d}\n", .{circuit_sizes_list.items[i]});
        result *= circuit_sizes_list.items[i];
    }

    std.debug.print("Product of circuit sizes is {d}\n", .{result});
}

