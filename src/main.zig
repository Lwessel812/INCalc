const std = @import("std");
const Io = std.Io;

const INC = @import("INCalc");

const State = struct {
    state: stateEnum = .getInput,
    usedRangeArg: bool = false,
    usedBearingArg: bool = false,
};

const stateEnum = enum {
    getInput,
    calculate,
    output,
};

pub fn main(init: std.process.Init) !void {
    @setFloatMode(.optimized);
    // std.debug.print("Debug {s}.\n", .{"INCalc"});

    const arena: std.mem.Allocator = init.arena.allocator();

    const args = init.minimal.args.toSlice(arena) catch |err| {
        std.log.err("{}\n", .{err});
        return err;
    };
    // for (args) |arg| {
    //     std.log.info("arg: {s}", .{arg});
    // }

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout = &stdout_file_writer.interface;

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_file_reader: Io.File.Reader = .init(.stdin(), io, &stdin_buffer);
    const stdin = &stdin_file_reader.interface;

    // stdout.print("Start of {s}\n", .{"INCalc"}) catch |err| {
    //     std.log.err("{any}\n", .{err});
    //     return err;
    // };

    // stdout.print("Input range: {any}\n", .{args[1]}) catch |err| {
    //     std.log.err("{any}\n", .{err});
    //     return err;
    // };

    var state: State = .{ .state = .getInput };

    var target: u32 = 0;

    while (true) {
        state.state = .getInput;

        var range: f32 = undefined;

        while (state.state == .getInput) {
            range = 0.0;

            if (args.len >= 2 and state.usedRangeArg == false) {
                range = std.fmt.parseFloat(f32, args[1]) catch |err| {
                    std.log.err("{}\n", .{err});
                    return err;
                };

                state.usedRangeArg = true;
            } else {
                stdout.print("T{d} Range (km): ", .{target}) catch |err| {
                    std.log.err("{}\n", .{err});
                    return err;
                };

                stdout.flush() catch |err| {
                    std.log.err("{}\n", .{err});
                    return err;
                };

                const rawInputOpt = stdin.takeDelimiter('\n') catch |err| {
                    std.log.err("{}\n", .{err});
                    return err;
                };
                const rawInput = rawInputOpt.?;
                // std.debug.print("raw: {s}\n", .{rawInput});

                const cleanInput = std.mem.trim(u8, rawInput, "\r");
                // std.debug.print("cleaned: {s}\n", .{cleanInput});

                range = std.fmt.parseFloat(f32, cleanInput) catch |err| {
                    std.log.err("{}\n", .{err});
                    return err;
                };
            }

            state.state = .calculate;

            if (range <= 0) {
                std.log.err("Range is zero or negative, please input a valid range [0:30].", .{});
                state.state = .getInput;
            }

            if (range > 30.0) {
                std.log.err("Range is greater than 30, please input a valid range [0:30].", .{});
                range = 0.0;
                state.state = .getInput;
            }
        }

        var bearing: f32 = 0.0;

        if (args.len >= 3 and state.usedBearingArg == false) {
            bearing = std.fmt.parseFloat(f32, args[2]) catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };

            state.usedBearingArg = true;
        } else {
            stdout.print("T{d} Bearing (deg): ", .{target}) catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };

            stdout.flush() catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };

            const rawInputOpt = stdin.takeDelimiter('\n') catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };
            const rawInput = rawInputOpt.?;
            // std.debug.print("raw: {s}\n", .{rawInput});

            var cleanInput: []const u8 = "0.0";

            cleanInput = std.mem.trim(u8, rawInput, "\r");
            // std.debug.print("cleaned: {s}\n", .{cleanInput});

            if (cleanInput.len == 0) {
                cleanInput = "0.0";
            }

            bearing = std.fmt.parseFloat(f32, cleanInput) catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };
        }

        state.state = .calculate;

        const nCharges: u8 = INC.nCharges(range) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        const elevation: f32 = INC.elevation(range) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        state.state = .output;

        stdout.print("\nTarget {d}\n", .{target}) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        stdout.print("Charges: {d} ", .{nCharges}) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        stdout.print("Elevation: {d:.2} ", .{elevation}) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        if (bearing != 0.0) {
            stdout.print("Bearing: {d:.2}", .{bearing}) catch |err| {
                std.log.err("{}\n", .{err});
                return err;
            };
        }

        stdout.print("\n\n", .{}) catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        // INC.structLayout(INC.POI);

        stdout.flush() catch |err| {
            std.log.err("{}\n", .{err});
            return err;
        };

        target += 1;
    }
}
