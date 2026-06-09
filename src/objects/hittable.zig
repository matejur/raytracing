const Sphere = @import("Sphere.zig");
const Ray = @import("../Ray.zig");

const Pos3 = @import("../math/Pos3.zig");
const Vec3 = @import("../math/Vec3.zig");

pub const HitRecord = struct {
    pos: Pos3,
    normal: Vec3,
    t: f32,
    front_face: bool,

    pub fn new(pos: Pos3, outward_normal: Vec3, t: f32, ray: *const Ray) HitRecord {
        const front_face = ray.dir.dot(outward_normal) < 0;

        return .{
            .pos = pos,
            .normal = if (front_face) outward_normal else outward_normal.neg(),
            .front_face = front_face,
            .t = t,
        };
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, ray: *const Ray, tMin: f32, tMax: f32) ?HitRecord {
        return switch (self) {
            .sphere => |sphere| sphere.hit(ray, tMin, tMax),
        };
    }
};

pub const World = struct {
    objects: []const Hittable,

    pub fn hit(self: *World, ray: *const Ray, tMin: f32, tMax: f32) ?HitRecord {
        var record: ?HitRecord = null;
        var closest = tMax;

        for (self.objects) |object| {
            const did_hit = object.hit(ray, tMin, closest);
            if (did_hit) |hit_info| {
                record = hit_info;
                closest = hit_info.t;
            }
        }

        return record;
    }
};
