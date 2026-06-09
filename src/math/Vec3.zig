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

const common = Common(Vec3);
pub const new = common.new;
pub const scale = common.scale;
pub const add = common.add(Vec3, Vec3, Vec3);
