const print = @import("std").debug.print;

const Color = @import("math/Color.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");

const Ray = @This();

orig: Pos3,
dir: Vec3,

pub fn new(origin: Pos3, dir: Vec3) Ray {
    return .{ .orig = origin, .dir = dir };
}

pub fn at(self: Ray, t: f32) Pos3 {
    return self.orig.addVec(self.dir.scale(t));
}

pub fn color(self: Ray) Color {
    const center = Pos3.new(0, 0, -1);
    const did_hit = hit_sphere(center, 0.5, &self);
    if (did_hit) |t| {
        const N = self.at(t).sub(center).normalize();
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

fn hit_sphere(center: Pos3, radius: f32, ray: *const Ray) ?f32 {
    const oc = center.sub(ray.orig);
    const a = ray.dir.lengthSqr();
    const b = -2.0 * ray.dir.dot(oc);
    const c = oc.lengthSqr() - radius * radius;
    const D = b * b - 4.0 * a * c;

    if (D < 0) return null;
    return (-b - @sqrt(D)) / (2 * a);
}
