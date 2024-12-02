// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   part1.zig                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2024/12/01 21:38:50 by pollivie          #+#    #+#             //
//   Updated: 2024/12/01 21:38:50 by pollivie         ###   ########.fr       //
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

    var distance_list: std.ArrayList(u32) = .init(allocator);
    defer distance_list.deinit();

    for (list_left.items, list_right.items) |left, right| {
        try distance_list.append(@abs(left - right));
    }

    var result: u64 = 0;
    for (distance_list.items) |distance| {
        result += distance;
    }

    std.debug.print("part1 : result = {d}\n", .{result});
}
