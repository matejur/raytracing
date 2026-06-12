const std = @import("std");
const Common = @import("common.zig").Common;

r: f32,
g: f32,
b: f32,

const Color = @This();

pub fn write_color(self: *Color, writer: *std.Io.Writer) !void {
    self.clamp(0, 1);
    self.to_gamma();
    const pixel = [_]u8{
        @floor(self.r * 255),
        @floor(self.g * 255),
        @floor(self.b * 255),
    };

    _ = try writer.write(&pixel);
}

pub fn to_gamma(self: *Color) void {
    inline for (@typeInfo(Color).@"struct".fields) |field| {
        const val = @field(self, field.name);
        if (val > 0) @field(self, field.name) = @sqrt(val);
    }
}

pub fn lerp(c1: Color, c2: Color, t: f32) Color {
    std.debug.assert(0 <= t and t <= 1);

    return c1.scale(1 - t).add(c2.scale(t));
}

const common = Common(Color);
pub const new = common.new;
pub const zero = common.zero;
pub const scale = common.scale;
pub const add = common.add(Color, Color, Color);
pub const clamp = common.clamp;
pub const mul = common.mul;
