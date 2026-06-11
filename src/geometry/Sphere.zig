const Pos3 = @import("../math/Pos3.zig");
const Ray = @import("../Ray.zig");

const HitRecord = @import("../World.zig").HitRecord;

center: Pos3,
radius: f32,

const Sphere = @This();

pub fn hit(self: *const Sphere, ray: *const Ray, tMin: f32, tMax: f32) ?HitRecord {
    const oc = self.center.sub(ray.orig);
    const a = ray.dir.lengthSqr();
    const h = ray.dir.dot(oc);
    const c = oc.lengthSqr() - self.radius * self.radius;
    const D = h * h - a * c;

    if (D < 0) return null;

    const sqrtD = @sqrt(D);

    var root = (h - sqrtD) / a;
    if (root <= tMin or tMax <= root) {
        root = (h + sqrtD) / a;
        if (root <= tMin or tMax <= root) {
            return null;
        }
    }

    const hitPos = ray.at(root);
    return HitRecord.new(
        hitPos,
        hitPos.sub(self.center).scale(1 / self.radius),
        root,
        ray,
    );
}
