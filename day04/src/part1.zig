// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   part1.zig                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/12/02 09:05:19 by pollivie          #+#    #+#             //
//   Updated: 2024/12/02 09:05:20 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");

const Direction = enum {
    north,
    south,
    east,
    west,
    north_east,
    north_west,
    south_east,
    south_west,

    fn toPos(direction: Direction) Position {
        return switch (direction) {
            .north => Position.init(0, -1),
            .south => Position.init(0, 1),
            .east => Position.init(1, 0),
            .west => Position.init(-1, 0),
            .north_east => Position.init(1, -1),
            .south_east => Position.init(1, 1),
            .north_west => Position.init(-1, -1),
            .south_west => Position.init(-1, 1),
        };
    }

    const directions = [_]Direction{ Direction.north, .north_east, .east, .south_east, .south, .south_west, .west, .north_west };
};

const Position = struct {
    x: i32,
    y: i32,

    fn init(x: i32, y: i32) Position {
        return .{
            .x = x,
            .y = y,
        };
    }

    fn insideRangeOrNull(pos: Position, min: Position, max: Position) ?Position {
        if (pos.x < min.x or pos.x > max.x) return null;
        if (pos.y < min.y or pos.y > max.y) return null;
        return pos;
    }

    fn add(p1: Position, p2: Position) Position {
        return Position.init(p1.x + p2.x, p1.y + p2.y);
    }
};

fn buildGrid(data: []const u8, allocator: std.mem.Allocator) []const []const u8 {
    var list: std.ArrayList([]const u8) = .init(allocator);
    defer list.deinit();
    var line_iter = std.mem.tokenizeAny(u8, data, "\n");
    while (line_iter.next()) |line| {
        list.append(line) catch unreachable;
    }
    return list.toOwnedSlice() catch unreachable;
}

pub fn main() !void {
    var arena_allocator: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();
    const input = @embedFile("inputs/inputs.txt");
    const grid = buildGrid(input, arena);
    const min_pos: Position = .init(0, 0);
    const max_pos: Position = .init(@intCast(grid[0].len - 1), @intCast(grid.len - 1));

    const directions = Direction.directions;
    var count: usize = 0;

    for (grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            const start_pos = Position.init(@intCast(x), @intCast(y));

            for (directions) |dir| {
                var pos = start_pos;
                var valid = true;

                for (0..4) |step| {
                    const bounded_pos = Position.insideRangeOrNull(pos, min_pos, max_pos);

                    if (bounded_pos == null or grid[@intCast(bounded_pos.?.y)][@intCast(bounded_pos.?.x)] != "XMAS"[step]) {
                        valid = false;
                        break;
                    }
                    pos = Position.add(pos, Direction.toPos(dir));
                }

                if (valid) {
                    count += 1;
                }
            }
        }
    }

    std.debug.print("result1: {}\n", .{count});
}
