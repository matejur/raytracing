const std = @import("std");

const Color = @import("../math/Color.zig");
const Vec3 = @import("../math/Vec3.zig");
const Ray = @import("../Ray.zig");
const Material = @import("../materials/material.zig").Material;
const HitRecord = @import("../World.zig").HitRecord;
const utils = @import("../utility.zig");

const Dielectric = @This();

refraction_index: f32,

pub fn new(refraction_index: f32) Material {
    return .{ .dielectric = .{ .refraction_index = refraction_index } };
}

pub fn scatter(self: Dielectric, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
    attenuation.* = Color.new(1.0, 1.0, 1.0);

    var ri = self.refraction_index;
    if (hit_info.front_face) {
        ri = 1.0 / ri;
    }

    const unit_dir = ray_in.dir.normalize();
    const cos_theta = @min(unit_dir.neg().dot(hit_info.normal), 1.0);
    const sin_theta = @sqrt(1 - cos_theta * cos_theta);

    const cannot_refract = ri * sin_theta > 1.0;

    if (cannot_refract or reflectance(cos_theta, ri) > utils.random())
        return Ray.new(hit_info.pos, unit_dir.reflect(hit_info.normal));

    return Ray.new(hit_info.pos, unit_dir.refract(hit_info.normal, ri));
}

fn reflectance(cosine: f32, ri: f32) f32 {
    var r0 = (1 - ri) / (1 + ri);
    r0 = r0 * r0;
    return r0 + (1 - r0) * std.math.pow(f32, 1 - cosine, 5);
}
