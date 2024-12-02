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
const opt = @import("build_options");

fn isSafe(items: []i32) bool {
    var is_ascending = true;
    var is_descending = true;
    for (items[0 .. items.len - 1], items[1..]) |n0, n1| {
        const diff = @abs(n0 - n1);
        if (diff < 1 or diff > 3) return (false);

        if (n0 < n1) {
            is_descending = false;
        }

        if (n0 > n1) {
            is_ascending = false;
        }
    }

    if ((is_ascending and is_descending) or (!is_ascending and !is_descending)) {
        return (false);
    } else {
        return (true);
    }
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();

    var arena: std.heap.ArenaAllocator = .init(gpa.allocator());
    defer arena.deinit();

    const allocator = gpa.allocator();
    const cwd = std.fs.cwd();

    const input_file = try cwd.openFile(opt.path, .{ .mode = .read_only });
    defer input_file.close();

    const input_text = try input_file.readToEndAlloc(allocator, std.math.maxInt(i32));
    defer allocator.free(input_text);

    var result: i32 = 0;
    var line_iter = std.mem.tokenizeScalar(u8, input_text, '\n');
    while (line_iter.next()) |input_line| {
        defer _ = arena.reset(.retain_capacity);
        var input_list: std.ArrayList(i32) = .init(arena.allocator());

        var input_iter = std.mem.tokenizeScalar(u8, input_line, ' ');
        while (input_iter.next()) |number| {
            try input_list.append(try std.fmt.parseInt(i32, number, 10));
        }

        const safety_report = try input_list.toOwnedSlice();
        result += @intFromBool(isSafe(safety_report));
    }
    std.debug.print("result1 = {d}\n", .{result});
}
