const std = @import("std");

const print = std.debug.print;

const Color = @import("math/Color.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");
const Interval = @import("math/Interval.zig");

const World = @import("World.zig");

const Ray = @This();

orig: Pos3,
dir: Vec3,

pub fn new(origin: Pos3, dir: Vec3) Ray {
    return .{ .orig = origin, .dir = dir };
}

pub fn at(self: Ray, t: f32) Pos3 {
    return self.orig.addVec(self.dir.scale(t));
}

pub fn color(self: *const Ray, world: *const World, bounces_remaining: u32) Color {
    if (bounces_remaining <= 0) return Color.new(0, 0, 0);

    const did_hit = world.hit(self, Interval.new(0.001, std.math.inf(f32)));
    if (did_hit) |hit_info| {
        const dir = hit_info.normal.add(Vec3.random_unit_vector());
        return color(&Ray.new(hit_info.pos, dir), world, bounces_remaining - 1).scale(0.5);
    }

    const unit_dir = self.dir.normalize();
    const a = 0.5 * (unit_dir.y + 1.0);
    return Color.lerp(
        Color{ .r = 1.0, .g = 1.0, .b = 1.0 },
        Color{ .r = 0.5, .g = 0.7, .b = 1.0 },
        a,
    );
}
