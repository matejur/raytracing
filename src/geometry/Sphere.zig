const Pos3 = @import("../math/Pos3.zig");
const Interval = @import("../math/Interval.zig");
const Ray = @import("../Ray.zig");
const Material = @import("../materials/material.zig").Material;

const HitRecord = @import("../World.zig").HitRecord;

center: Pos3,
radius: f32,
material: *const Material,

const Sphere = @This();

pub fn hit(self: *const Sphere, ray: *const Ray, length_minmax: Interval) ?HitRecord {
    const oc = self.center.sub(ray.orig);
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
        hitPos.sub(self.center).scale(1 / self.radius),
        root,
        ray,
        self.material,
    );
}
