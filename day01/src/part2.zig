// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   part2.zig                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/12/01 21:38:43 by pollivie          #+#    #+#             //
//   Updated: 2024/12/01 21:38:44 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const opt = @import("build_options");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const cwd = std.fs.cwd();

    const input_file = try cwd.openFile(opt.path, .{ .mode = .read_only });
    defer input_file.close();

    const input_text = try input_file.readToEndAlloc(allocator, std.math.maxInt(i32));
    defer allocator.free(input_text);

    var list_left: std.ArrayList(i32) = .init(allocator);
    defer list_left.deinit();

    var list_right: std.ArrayList(i32) = .init(allocator);
    defer list_right.deinit();

    var line_iter = std.mem.tokenizeAny(u8, input_text, "\n\r");
    while (line_iter.next()) |current_line| {
        var entry_iter = std.mem.tokenizeAny(u8, current_line, " \t");
        const left_entry = entry_iter.next() orelse break;
        const right_entry = entry_iter.next() orelse break;

        const left_entry_value = try std.fmt.parseInt(i32, left_entry, 10);
        const right_entry_value = try std.fmt.parseInt(i32, right_entry, 10);
        try list_left.append(left_entry_value);
        try list_right.append(right_entry_value);
    }

    std.sort.block(i32, list_left.items, {}, std.sort.desc(i32));
    std.sort.block(i32, list_right.items, {}, std.sort.desc(i32));

    const right_min, const right_max = std.mem.minMax(i32, list_right.items);

    const right_span: usize = @abs(right_max - right_min);

    const right_value_counter: []i32 = try allocator.alloc(i32, right_span + 1);
    defer allocator.free(right_value_counter);
    @memset(right_value_counter, 0);

    for (list_right.items) |item| {
        right_value_counter[@as(usize, @intCast(item - right_min))] += 1;
    }

    var result: i128 = 0;
    for (list_left.items) |item| {
        if (item >= right_min and item <= right_max)
            result += right_value_counter[@as(usize, @intCast(item - right_min))] * item;
    }

    std.debug.print("part2 : result = {d}\n", .{result});
}
