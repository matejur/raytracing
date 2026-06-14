const std = @import("std");

const Color = @import("math/Color.zig");
const Vec3 = @import("math/Vec3.zig");
const Ray = @import("Ray.zig");
const HitRecord = Ray.HitRecord;

const textures = @import("textures.zig");
const Texture = textures.Texture;
const SolidColor = textures.SolidColor;

const utils = @import("utility.zig");

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: *const Material, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
        return switch (self.*) {
            .lambertian => |lamb| lamb.scatter(ray_in, hit_info, attenuation),
            .metal => |metal| metal.scatter(ray_in, hit_info, attenuation),
            .dielectric => |dielectric| dielectric.scatter(ray_in, hit_info, attenuation),
        };
    }
};

pub const Lambertian = struct {
    tex: *Texture,

    pub fn new(tex: *Texture) Material {
        return .{ .lambertian = .{ .tex = tex } };
    }

    pub fn scatter(self: Lambertian, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
        var scatter_dir = hit_info.normal.add(Vec3.random_unit_vector());
        if (scatter_dir.near_zero()) {
            scatter_dir = hit_info.normal;
        }
        attenuation.* = self.tex.value(hit_info.u, hit_info.v, hit_info.pos);
        return .{ .orig = hit_info.pos, .dir = scatter_dir, .t = ray_in.t };
    }
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f32,

    pub fn new(albedo: Color, fuzz: f32) Material {
        return .{ .metal = .{ .albedo = albedo, .fuzz = @min(1, fuzz) } };
    }

    pub fn scatter(self: Metal, ray_in: *const Ray, hit_info: *const HitRecord, attenuation: *Color) ?Ray {
        var reflected = ray_in.dir.reflect(hit_info.normal);
        reflected = reflected.normalize().add(Vec3.random_unit_vector().scale(self.fuzz));
        attenuation.* = self.albedo;
        return .{ .orig = hit_info.pos, .dir = reflected, .t = ray_in.t };
    }
};

pub const Dielectric = struct {
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

        const dir = if (cannot_refract or reflectance(cos_theta, ri) > utils.random())
            unit_dir.reflect(hit_info.normal)
        else
            unit_dir.refract(hit_info.normal, ri);

        return .{ .orig = hit_info.pos, .dir = dir, .t = ray_in.t };
    }

    fn reflectance(cosine: f32, ri: f32) f32 {
        var r0 = (1 - ri) / (1 + ri);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f32, 1 - cosine, 5);
    }
};
