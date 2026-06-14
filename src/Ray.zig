const std = @import("std");

const Color = @import("math/Color.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");
const Interval = @import("math/Interval.zig");

const Material = @import("materials.zig").Material;
const Sphere = @import("primitives/Sphere.zig");

const Scene = @import("Scene.zig");
const bvh = @import("bvh.zig");
const BvhNode = bvh.BvhNode;
const AABB = bvh.AABB;

const Ray = @This();

orig: Pos3,
dir: Vec3,
t: f32 = 0,

pub fn at(self: Ray, t: f32) Pos3 {
    return self.orig.addVec(self.dir.scale(t));
}

pub fn color(self: *const Ray, scene: *const Scene, bounces_remaining: u32) Color {
    if (bounces_remaining <= 0) return Color.new(0, 0, 0);

    const did_hit = scene.hit(self, Interval.new(0.001, std.math.inf(f32)));
    if (did_hit) |hit_info| {
        var attenuation: Color = undefined;
        const did_scatter = hit_info.material.scatter(self, &hit_info, &attenuation);
        if (did_scatter) |scattered_ray| {
            return attenuation.mul(scattered_ray.color(scene, bounces_remaining - 1));
        }
        return Color.new(0, 0, 0);
    }

    const unit_dir = self.dir.normalize();
    const a = 0.5 * (unit_dir.y + 1.0);
    return Color.lerp(
        Color{ .r = 1.0, .g = 1.0, .b = 1.0 },
        Color{ .r = 0.5, .g = 0.7, .b = 1.0 },
        a,
    );
}

pub const Hittable = union(enum) {
    sphere: Sphere,
    bvh: BvhNode,

    pub fn hit(self: *const Hittable, ray: *const Ray, length_minmax: Interval) ?HitRecord {
        return switch (self.*) {
            .sphere => |s| s.hit(ray, length_minmax),
            .bvh => |b| b.hit(ray, length_minmax),
        };
    }

    pub fn bounding_box(self: *const Hittable) AABB {
        return switch (self.*) {
            .sphere => |s| s.bbox,
            .bvh => |b| b.bbox,
        };
    }
};

pub const HitRecord = struct {
    pos: Pos3,
    normal: Vec3,
    dist_from_camera: f32,
    front_face: bool,
    material: *const Material,
    u: f32,
    v: f32,

    pub fn new(pos: Pos3, outward_normal: Vec3, dist_from_camera: f32, ray: *const Ray, material: *const Material, u: f32, v: f32) HitRecord {
        const front_face = ray.dir.dot(outward_normal) < 0;

        return .{
            .pos = pos,
            .normal = if (front_face) outward_normal else outward_normal.neg(),
            .front_face = front_face,
            .dist_from_camera = dist_from_camera,
            .material = material,
            .u = u,
            .v = v,
        };
    }
};
