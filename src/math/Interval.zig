const Interval = @This();

min: f32,
max: f32,

pub fn new(min: f32, max: f32) Interval {
    return .{
        .min = min,
        .max = max,
    };
}

pub fn contains(self: Interval, x: f32) bool {
    return self.min < x and x < self.max;
}
