const std = @import("std");

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn zero() Vec3 {
        return .{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn add(self: Vec3, v: Vec3) Vec3 {
        return .{
            .x = self.x + v.x,
            .y = self.y + v.y,
            .z = self.z + v.z,
        };
    }

    pub fn sub(self: Vec3, v: Vec3) Vec3 {
        return .{
            .x = self.x - v.x,
            .y = self.y - v.y,
            .z = self.z - v.z,
        };
    }

    pub fn div(self: Vec3, s: f32) Vec3 {
        return .{
            .x = self.x / s,
            .y = self.y / s,
            .z = self.z / s,
        };
    }

    pub fn scale(self: Vec3, s: f32) Vec3 {
        return .{
            .x = self.x * s,
            .y = self.y * s,
            .z = self.z * s,
        };
    }

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
        return self.div(self.length());
    }
};

pub const Pos3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn new(x: f32, y: f32, z: f32) Pos3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn zero() Pos3 {
        return .{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn add(self: Pos3, v: Vec3) Pos3 {
        return .{
            .x = self.x + v.x,
            .y = self.y + v.y,
            .z = self.z + v.z,
        };
    }

    pub fn sub(self: Pos3, v: anytype) switch (@TypeOf(v)) {
        Vec3 => Pos3,
        Pos3 => Vec3,
        else => |t| @compileError("Can`t subtract " ++ @typeName(t) ++ " from a point!"),
    } {
        return .{
            .x = self.x - v.x,
            .y = self.y - v.y,
            .z = self.z - v.z,
        };
    }
};
