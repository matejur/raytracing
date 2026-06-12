const HitRecord = @import("../World.zig").HitRecord;
const Color = @import("../math/Color.zig");
const Ray = @import("../Ray.zig");

const Lambertian = @import("../materials/Lambertian.zig");
const Metal = @import("../materials/Metal.zig");
const Dielectric = @import("../materials/Dielectric.zig");

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
