// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   part2.zig                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/12/02 09:05:28 by pollivie          #+#    #+#             //
//   Updated: 2024/12/02 09:05:29 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");

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

    var count: usize = 0;

    for (1..grid.len - 1) |row| {
        for (1..grid[row].len - 1) |col| {
            if (grid[row][col] == 'A' and isValidXmasPattern(grid, row, col)) {
                count += 1;
            } else continue;
        }
    }

    std.debug.print("result2: {}\n", .{count});
}

fn isValidXmasPattern(grid: []const []const u8, row: usize, col: usize) bool {
    const top_left = grid[row - 1][col - 1];
    const top_right = grid[row - 1][col + 1];
    const bot_left = grid[row + 1][col - 1];
    const bot_right = grid[row + 1][col + 1];

    return (top_left == 'M' and top_right == 'M' and bot_left == 'S' and bot_right == 'S') or
        (top_left == 'S' and top_right == 'S' and bot_left == 'M' and bot_right == 'M') or
        (top_left == 'M' and top_right == 'S' and bot_left == 'M' and bot_right == 'S') or
        (top_left == 'S' and top_right == 'M' and bot_left == 'S' and bot_right == 'M');
}
