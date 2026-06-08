const Color = @import("Color.zig");

const geometry = @import("geometry.zig");
const Pos3 = geometry.Pos3;
const Vec3 = geometry.Vec3;

const Ray = @This();

orig: Pos3,
dir: Vec3,

pub fn new(origin: Pos3, dir: Vec3) Ray {
    return .{ .orig = origin, .dir = dir };
}

pub fn at(self: Ray, t: f32) Pos3 {
    return self.orig.addVector(self.dir.scale(t));
}

pub fn color(self: Ray) Color {
    if (hit_sphere(Pos3.new(0, 0, -1), 0.5, &self)) {
        return Color.new(1, 0, 0);
    }

    const unit_dir = self.dir.normalize();
    const a = 0.5 * (unit_dir.y + 1.0);
    return Color.lerp(Color.new(1.0, 1.0, 1.0), Color.new(0.5, 0.7, 1.0), a);
}

fn hit_sphere(center: Pos3, radius: f32, ray: *const Ray) bool {
    const oc = center.sub(ray.orig);
    const a = ray.dir.lengthSqr();
    const b = -2.0 * ray.dir.dot(oc);
    const c = oc.lengthSqr() - radius * radius;
    const D = b * b - 4.0 * a * c;

    return D >= 0;
}
