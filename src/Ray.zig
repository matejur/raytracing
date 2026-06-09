const print = @import("std").debug.print;

const Color = @import("math/Color.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");

const hittable = @import("objects/hittable.zig");
const World = hittable.World;

const Ray = @This();

orig: Pos3,
dir: Vec3,

pub fn new(origin: Pos3, dir: Vec3) Ray {
    return .{ .orig = origin, .dir = dir };
}

pub fn at(self: Ray, t: f32) Pos3 {
    return self.orig.addVec(self.dir.scale(t));
}

pub fn color(self: *const Ray, world: *World) Color {
    const did_hit = world.hit(self, 0, 100);
    if (did_hit) |hit_info| {
        const N = hit_info.normal;
        return Color.new(N.x + 1, N.y + 1, N.z + 1).scale(0.5);
    }

    const unit_dir = self.dir.normalize();
    const a = 0.5 * (unit_dir.y + 1.0);
    return Color.lerp(
        Color{ .r = 1.0, .g = 1.0, .b = 1.0 },
        Color{ .r = 0.5, .g = 0.7, .b = 1.0 },
        a,
    );
}
