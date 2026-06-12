const std = @import("std");
const Common = @import("common.zig").Common;

x: f32,
y: f32,
z: f32,

const Vec3 = @This();

pub fn length(self: Vec3) f32 {
    return @sqrt(self.lengthSqr());
}

pub fn lengthSqr(self: Vec3) f32 {
    return self.dot(self);
}

pub fn dot(self: Vec3, other: Vec3) f32 {
    return self.x * other.x + self.y * other.y + self.z * other.z;
}

pub fn normalize(self: Vec3) Vec3 {
    return self.scale(1 / self.length());
}

pub fn near_zero(self: Vec3) bool {
    const eps = 1e-6;

    return @abs(self.x) < eps and @abs(self.y) < eps and @abs(self.z) < eps;
}

pub fn reflect(self: Vec3, n: Vec3) Vec3 {
    std.debug.assert(@abs(n.lengthSqr() - 1) < 1e-3);
    return self.sub(n.scale(2 * self.dot(n)));
}

pub fn random_unit_vector() Vec3 {
    while (true) {
        const p = Vec3.random_minmax(-1, 1);
        const lensq = p.lengthSqr();
        if (1e-30 < lensq and lensq <= 1) return p.scale(1 / lensq);
    }
}

pub fn random_on_hemisphere(normal: *const Vec3) Vec3 {
    const on_unit_sphere = random_unit_vector();
    if (normal.dot(on_unit_sphere) > 0) return on_unit_sphere;
    return on_unit_sphere.neg();
}

const common = Common(Vec3);
pub const new = common.new;
pub const scale = common.scale;
pub const add = common.add(Vec3, Vec3, Vec3);
pub const sub = common.sub(Vec3, Vec3, Vec3);
pub const neg = common.neg;
pub const random_minmax = common.random_minmax;
