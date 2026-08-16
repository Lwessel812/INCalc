const std = @import("std");
const Io = std.Io;

const INC = @import("INCalc");

const State = struct {
    state: stateEnum = .getInput,
    shouldExit: bool = false,
};

const stateEnum = enum {
    getInput,
    calculate,
    output,
    exit,
};

pub fn main(init: std.process.Init) !void {
    @setFloatMode(.optimized);
    // std.debug.print("Debug {s}.\n", .{"INCalc"});

    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
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

    // try stdout.print("Start of {s}\n", .{"INCalc"});

    // try stdout.print("Input range: {any}\n", .{args[1]});

    var state: State = .{};

    var target: u32 = 1;
    var range: f32 = 0.0;
    var bearing: f32 = 0.0;

    if (args.len > 1) {
        bearing = std.fmt.parseFloat(f32, args[2]) catch |err| bearing: {
            std.log.err("{} Input valid bearing argument [0.0:360.0]\n", .{err});
            break :bearing 0.0;
        };

        range = std.fmt.parseFloat(f32, args[2]) catch |err| range: {
            std.log.err("{} Input valid range argument (0.00:30.00]\n", .{err});
            break :range 30.0;
        };

        state.shouldExit = true;
        state.state = .calculate;
    }

    while (true) {
        while (state.state == .getInput) {
            bearing = 0.0;

            try stdout.print("T{d} Bearing (deg): ", .{target});
            try stdout.flush();

            const rawBearingInputOpt = try stdin.takeDelimiter('\n');
            const rawBearingInput = rawBearingInputOpt.?;
            // std.debug.print("raw: {s}\n", .{rawBearingInput});

            var cleanBearingInput: []const u8 = "0.0";

            cleanBearingInput = std.mem.trim(u8, rawBearingInput, "\r");
            // std.debug.print("cleaned: {s}\n", .{cleanBearingInput});

            if (cleanBearingInput.len == 0) {
                cleanBearingInput = "0.0";
            }

            bearing = try std.fmt.parseFloat(f32, cleanBearingInput);

            range = 0.0;

            try stdout.print("T{d} Range (km): ", .{target});
            try stdout.flush();

            const rawRangeInputOpt = try stdin.takeDelimiter('\n');
            const rawRangeInput = rawRangeInputOpt.?;
            // std.debug.print("raw: {s}\n", .{rawRangeInput});

            const cleanRangeInput = std.mem.trim(u8, rawRangeInput, "\r");
            // std.debug.print("cleaned: {s}\n", .{cleanRangeInput});

            range = try std.fmt.parseFloat(f32, cleanRangeInput);

            state.state = .calculate;

            if (bearing < 0) {
                std.log.err("Bearing is negative, please input a valid bearing [0.0:360.0].", .{});
                state.state = .getInput;
            }

            if (bearing > 360.0) {
                std.log.err("Bearing is greater than 360, please input a bearing [0.0:360].", .{});
                range = 0.0;
                state.state = .getInput;
            }

            if (range <= 0) {
                std.log.err("Range is zero or negative, please input a valid range (0.00:30.00].", .{});
                state.state = .getInput;
            }

            if (range > 30.0) {
                std.log.err("Range is greater than 30, please input a valid range (0.00:30.00].", .{});
                range = 0.0;
                state.state = .getInput;
            }
        }

        var nCharges: u8 = 0;
        var elevation: f32 = 0.0;

        while (state.state == .calculate) {
            nCharges = INC.nCharges(range);
            elevation = INC.elevation(range);
            state.state = .output;
        }

        while (state.state == .output) {
            try stdout.print("\nTarget {d}\nCharges: {d} Elevation: {d:.2} Bearing: {d:.1}\n\n", .{ target, nCharges, elevation, bearing });
            state.state = .getInput;
        }

        // INC.structLayout(INC.POI);
        // INC.structLayout(State);

        try stdout.flush();

        if (state.shouldExit == true) {
            break;
        }

        target += 1;
    }
}
