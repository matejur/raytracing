const Pos3 = @import("../math/Pos3.zig");
const Interval = @import("../math/Interval.zig");
const Ray = @import("../Ray.zig");
const Material = @import("../materials/material.zig").Material;

const HitRecord = @import("../World.zig").HitRecord;

center: Ray,
radius: f32,
material: *const Material,

const Sphere = @This();

pub fn static(center: Pos3, radius: f32, material: *const Material) Sphere {
    return Sphere.moving(center, center, radius, material);
}

pub fn moving(start_center: Pos3, end_center: Pos3, radius: f32, material: *const Material) Sphere {
    return .{
        .center = .{ .orig = start_center, .dir = end_center.sub(start_center) },
        .radius = radius,
        .material = material,
    };
}

pub fn hit(self: *const Sphere, ray: *const Ray, length_minmax: Interval) ?HitRecord {
    const center_at_t = self.center.at(ray.t);

    const oc = center_at_t.sub(ray.orig);
    const a = ray.dir.lengthSqr();
    const h = ray.dir.dot(oc);
    const c = oc.lengthSqr() - self.radius * self.radius;
    const D = h * h - a * c;

    if (D < 0) return null;

    const sqrtD = @sqrt(D);

    var root = (h - sqrtD) / a;
    if (!length_minmax.contains(root)) {
        root = (h + sqrtD) / a;
        if (!length_minmax.contains(root)) {
            return null;
        }
    }

    const hitPos = ray.at(root);
    return HitRecord.new(
        hitPos,
        hitPos.sub(center_at_t).scale(1 / self.radius),
        root,
        ray,
        self.material,
    );
}
