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
const data = @embedFile("inputs/inputs.txt");

const State = enum {
    invalid,
    mul,
    lpar,
    num,
    sep,
    rpar,
    eof,
};

const Iterator = struct {
    const endl: u8 = 255;
    items: []const u8,
    index: usize,

    fn init(items: []const u8) Iterator {
        return .{
            .items = items,
            .index = 0,
        };
    }

    fn at(it: *const Iterator) usize {
        return it.index;
    }

    fn eof(it: *Iterator) bool {
        return if (it.index >= it.items.len) true else false;
    }

    fn curr(it: *Iterator) u8 {
        return it.peek(0);
    }

    fn peek(it: *Iterator, ahead: usize) u8 {
        return if (it.index + ahead >= it.items.len) Iterator.endl else it.items[it.index + ahead];
    }

    fn skip(it: *Iterator, n: usize) usize {
        return for (0..n) |i| {
            if (!it.advance()) break i;
        } else n;
    }

    fn match(it: *Iterator, cond: fn (u8) bool) usize {
        var count: usize = 0;
        while (!it.eof()) : (count += 1) {
            if (!cond(it.peek(1))) {
                it.index -= count;
                return count;
            }
            _ = it.advance();
        }
    }

    fn advance(it: *Iterator) bool {
        if (it.eof()) return (false);
        it.index += 1;
        return (true);
    }
};

pub fn main() !void {
    const input_text = data;
    var result: i64 = 0;
    var buffer: [3]u8 = undefined;
    @memset(&buffer, 0);

    var it = Iterator.init(input_text);
    var state: State = .invalid;
    var do_enabled: bool = true;
    var lhs: i32 = 0;
    var rhs: i32 = 0;
    var num_idx: usize = 0;

    while (!it.eof()) {
        state = switch (state) {
            State.invalid => st: {
                if (it.curr() == 'm' and it.peek(1) == 'u' and it.peek(2) == 'l') {
                    _ = it.skip(3);
                    break :st State.mul;
                } else if (it.curr() == 'd' and it.peek(1) == 'o' and it.peek(2) == '(' and it.peek(3) == ')') {
                    do_enabled = true;
                    _ = it.skip(4);
                    break :st State.invalid;
                } else if (it.curr() == 'd' and it.peek(1) == 'o' and it.peek(2) == 'n' and it.peek(3) == '\'' and it.peek(4) == 't' and it.peek(5) == '(' and it.peek(6) == ')') {
                    do_enabled = false;
                    _ = it.skip(7);
                    break :st State.invalid;
                } else {
                    _ = it.advance();
                    break :st State.invalid;
                }
            },

            State.mul => st: {
                if (it.curr() == '(') {
                    _ = it.advance();
                    break :st State.lpar;
                } else {
                    break :st State.invalid;
                }
            },

            State.lpar => st: {
                if (it.curr() >= '0' and it.curr() <= '9') {
                    num_idx = 0;
                    while (it.curr() >= '0' and it.curr() <= '9' and num_idx < buffer.len) : (num_idx += 1) {
                        buffer[num_idx] = it.curr();
                        _ = it.advance();
                    }
                    lhs = try std.fmt.parseInt(i32, buffer[0..num_idx], 10);
                    @memset(&buffer, 0);
                    num_idx = 0;
                    if (it.curr() == ',') {
                        _ = it.advance();
                        break :st State.sep;
                    } else {
                        break :st State.invalid;
                    }
                } else {
                    _ = it.advance();
                    break :st State.invalid;
                }
            },

            State.sep => st: {
                if (it.curr() >= '0' and it.curr() <= '9') {
                    num_idx = 0;
                    while (it.curr() >= '0' and it.curr() <= '9' and num_idx < buffer.len) : (num_idx += 1) {
                        buffer[num_idx] = it.curr();
                        _ = it.advance();
                    }
                    rhs = try std.fmt.parseInt(i32, buffer[0..num_idx], 10);
                    @memset(&buffer, 0);
                    num_idx = 0;
                    if (it.curr() == ')') {
                        _ = it.advance();
                        break :st State.rpar;
                    } else {
                        break :st State.invalid;
                    }
                } else {
                    _ = it.advance();
                    break :st State.invalid;
                }
            },

            State.rpar => st: {
                if (do_enabled) {
                    result += (lhs * rhs);
                }
                break :st State.invalid;
            },

            else => st: {
                _ = it.advance();
                break :st State.invalid;
            },
        };
    }

    std.debug.print("result = {d}\n", .{result});
}
