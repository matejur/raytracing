const Interval = @import("math/Interval.zig");
const Pos3 = @import("math/Pos3.zig");
const Ray = @import("Ray.zig");

const AABB = @This();

x: Interval,
y: Interval,
z: Interval,

pub const empty = AABB{
    .x = Interval.empty,
    .y = Interval.empty,
    .z = Interval.empty,
};

pub const universe = AABB{
    .x = Interval.universe,
    .y = Interval.universe,
    .z = Interval.universe,
};

pub fn from_points(p1: Pos3, p2: Pos3) AABB {
    return .{
        .x = .{ .min = @min(p1.x, p2.x), .max = @max(p1.x, p2.x) },
        .y = .{ .min = @min(p1.y, p2.y), .max = @max(p1.y, p2.y) },
        .z = .{ .min = @min(p1.z, p2.z), .max = @max(p1.z, p2.z) },
    };
}

pub fn combine(self: AABB, other: AABB) AABB {
    return .{
        .x = self.x.merge(other.x),
        .y = self.y.merge(other.y),
        .z = self.z.merge(other.z),
    };
}

// TODO: make this return an axis enum?
pub fn longest_axis(self: AABB) u32 {
    if (self.x.size() > self.y.size()) {
        return if (self.x.size() > self.z.size()) 0 else 2;
    }
    return if (self.y.size() > self.z.size()) 1 else 2;
}

pub fn hit(self: AABB, ray: *const Ray, length_minmax: Interval) bool {
    const ray_origin = ray.orig;
    const ray_dir = ray.dir;

    var interval = length_minmax;
    inline for (@typeInfo(AABB).@"struct".fields) |field| {
        const ax = @field(self, field.name);
        const inv = 1.0 / @field(ray_dir, field.name);

        const t0 = (ax.min - @field(ray_origin, field.name)) * inv;
        const t1 = (ax.max - @field(ray_origin, field.name)) * inv;

        if (t0 < t1) {
            if (t0 > interval.min) interval.min = t0;
            if (t1 < interval.max) interval.max = t1;
        } else {
            if (t1 > interval.min) interval.min = t1;
            if (t0 < interval.max) interval.max = t0;
        }

        if (interval.max <= interval.min) return false;
    }

    return true;
}
