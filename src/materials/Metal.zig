const Color = @import("../math/Color.zig");
const Vec3 = @import("../math/Vec3.zig");
const Ray = @import("../Ray.zig");
const Material = @import("../materials/material.zig").Material;
const HitRecord = @import("../World.zig").HitRecord;

const Metal = @This();

albedo: Color,
fuzz: f32,

pub fn new(albedo: Color, fuzz: f32) Material {
    return .{ .metal = .{ .albedo = albedo, .fuzz = @min(1, fuzz) } };
}

pub fn scatter(self: Metal, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
    var reflected = ray_in.dir.reflect(hit_info.normal);
    reflected = reflected.normalize().add(Vec3.random_unit_vector().scale(self.fuzz));
    attenuation.* = self.albedo;
    return Ray.new(hit_info.pos, reflected);
}
