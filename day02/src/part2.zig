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
const opt = @import("build_options");

fn inspectFurther(subitems: []i32) bool {
    var is_ascending = true;
    var is_descending = true;

    for (subitems[0 .. subitems.len - 1], subitems[1..]) |n0, n1| {
        const diff = @abs(n0 - n1);
        if (diff < 1 or diff > 3) {
            return (false);
        }
        if (n0 < n1) {
            is_descending = (false);
        }
        if (n0 > n1) {
            is_ascending = (false);
        }
    }

    if ((is_ascending and is_descending) or (!is_ascending and !is_descending)) {
        return (false);
    } else {
        return (true);
    }
}

pub fn isSafe(items: []i32) bool {
    var buffer: [1024]i32 = undefined;
    const len = items.len;
    if (inspectFurther(items)) {
        return (true);
    }

    for (items, 0..) |_, i| {
        var new_items = buffer[0 .. len - 1];
        @memcpy(new_items[0..i], items[0..i]);
        @memcpy(new_items[i..], items[i + 1 ..]);
        if (inspectFurther(new_items)) {
            return (true);
        }
    }
    return (false);
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
    std.debug.print("result2 = {d}\n", .{result});
}
