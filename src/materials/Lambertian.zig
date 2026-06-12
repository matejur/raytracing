const Color = @import("../math/Color.zig");
const Vec3 = @import("../math/Vec3.zig");
const Ray = @import("../Ray.zig");
const Material = @import("../materials/material.zig").Material;
const HitRecord = @import("../World.zig").HitRecord;

const Lambertian = @This();

albedo: Color,

pub fn new(albedo: Color) Material {
    return .{ .lambertian = .{ .albedo = albedo } };
}

pub fn scatter(self: Lambertian, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
    _ = ray_in;

    var scatter_dir = hit_info.normal.add(Vec3.random_unit_vector());
    if (scatter_dir.near_zero()) {
        scatter_dir = hit_info.normal;
    }
    attenuation.* = self.albedo;
    return Ray.new(hit_info.pos, scatter_dir);
}
