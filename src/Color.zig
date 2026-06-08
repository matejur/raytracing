const std = @import("std");

r: f32,
g: f32,
b: f32,

const Color = @This();

pub fn new(r: f32, g: f32, b: f32) Color {
    return .{
        .r = r,
        .g = g,
        .b = b,
    };
}

pub fn write_color(self: *const Color, writer: *std.Io.Writer) !void {
    const pixel = [_]u8{
        @floor(self.r * 255),
        @floor(self.g * 255),
        @floor(self.b * 255),
    };

    _ = try writer.write(&pixel);
}

pub fn lerp(c1: Color, c2: Color, t: f32) Color {
    std.debug.assert(0 <= t and t <= 1);

    return .{
        .r = c1.r * (1 - t) + c2.r * t,
        .g = c1.g * (1 - t) + c2.g * t,
        .b = c1.b * (1 - t) + c2.b * t,
    };
}
