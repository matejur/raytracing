const std = @import("std");
const Interval = @This();

min: f32,
max: f32,

pub const empty = Interval.new(std.math.inf(f32), -std.math.inf(f32));
pub const universe = Interval.new(-std.math.inf(f32), std.math.inf(f32));

pub fn new(min: f32, max: f32) Interval {
    return .{
        .min = min,
        .max = max,
    };
}

pub fn contains(self: Interval, x: f32) bool {
    return self.min < x and x < self.max;
}

pub fn size(self: Interval) f32 {
    return self.max - self.min;
}

pub fn merge(self: Interval, other: Interval) Interval {
    return .{
        .min = @min(self.min, other.min),
        .max = @max(self.max, other.max),
    };
}

pub fn expand(self: Interval, delta: f32) Interval {
    const p = delta / 2;
    return .{
        .min = self.min - p,
        .max = self.max + p,
    };
}
