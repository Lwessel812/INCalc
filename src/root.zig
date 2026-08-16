const std = @import("std");
const Io = std.Io;

/// Calculate minimum number of charges needed for the shot
/// Based only on range
pub fn nCharges(range: f32) u8 {
    const epsilon: f32 = 0.0001;

    if (range >= 25.0 + epsilon) {
        return 6;
    }

    if (range >= 20.0 + epsilon) {
        return 5;
    }

    if (range >= 15.0 + epsilon) {
        return 4;
    }

    if (range >= 10.0 + epsilon) {
        return 3;
    }

    if (range >= 5.0 + epsilon) {
        return 2;
    }

    if (range >= epsilon) {
        return 1;
    }

    unreachable;
}

/// Calculate elevation for the gun
/// Based only on range
pub fn elevation(range: f32) f32 {
    const epsilon: f32 = 0.0001;

    if (range >= 25.0 + epsilon) {
        return 2 * range;
    }

    if (range >= 20.0 + epsilon) {
        return 2.4 * range;
    }

    if (range >= 15.0 + epsilon) {
        return 3 * range;
    }

    if (range >= 10.0 + epsilon) {
        return 4 * range;
    }

    if (range >= 5.0 + epsilon) {
        return 6 * range;
    }

    if (range >= epsilon) {
        return 12 * range;
    }

    unreachable;
}

const POIType = enum {
    IronNest,
    Spotter,
    Refrence,
    Target,
};

pub const POI = struct {
    POIN: u32,
    x: f32,
    y: f32,
    POIT: POIType,
};

/// Convert grid square "S1,H7,53"
/// Into cartesian coordiantes Spotter 1 @ (7.55,0.35)
/// Breakdown for grid to cartesian is as follows
/// Grid X:
/// ```A,B,C,D,E,F,G,H,I,J,K ,L ,M ,N ,O ,P, Q, R, S, T```
/// ```0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19```
/// Grid Y:
/// ```1,2,3,4,5,6,7,8,9,10```
/// ```0,1,2,3,4,5,6,7,8,9```
/// Sub Grid:
/// ```0,1  ,2  ,3  ,4  ,5  ,6  ,7  ,8  ,9```
/// ```0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9```
/// Add an extra 0.5 km to center POI in grid square, this is usually true and should be good enough
pub fn gridToCartesian(grid: []u8) void {
    _ = grid;
}

pub fn structLayout(comptime T: type) void {
    const info = @typeInfo(T);
    if (info != .@"struct") {
        @compileError("structLayout only works with structs");
    }
    std.debug.print("Size of {s}: {}b [{}B]\n", .{ @typeName(T), @bitSizeOf(T), @sizeOf(T) });
    std.debug.print("Alignment: {}b [{}B]\n", .{ @alignOf(T) * 8, @alignOf(T) });
    std.debug.print("\nField offsets:\n", .{});

    var totalFieldBits: usize = 0;
    inline for (info.@"struct".fields) |field| {
        std.debug.print("{s}: offset {}b [{}B] (size {}b [{}B])\n", .{
            field.name,
            @offsetOf(T, field.name) * 8,
            @offsetOf(T, field.name),
            @bitSizeOf(field.type),
            @sizeOf(field.type),
        });
        totalFieldBits += @bitSizeOf(field.type);
    }

    const paddingBits = @bitSizeOf(T) - totalFieldBits;
    if (paddingBits > 0) {
        std.debug.print("\nPadding: {}b [{}B]\n", .{ paddingBits, paddingBits / 8 });
    } else {
        std.debug.print("\nPadding: 0b [0B]\n", .{});
    }
}
