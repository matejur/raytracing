const std = @import("std");

const Ray = @import("Ray.zig");
const Sphere = @import("geometry/Sphere.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");
const Interval = @import("math/Interval.zig");

const World = @This();

const world_size = 64;

objects: [64]Hittable = undefined,
count: usize = 0,

const WorldError = error{Full};

pub fn addObject(self: *World, object: anytype) WorldError!void {
    if (self.count >= world_size) return WorldError.Full;

    const T = @TypeOf(object);
    const hittable = switch (T) {
        Sphere => Hittable{ .sphere = object },
        else => @compileError(@typeName(T) ++ " can't be added to the world!"),
    };

    self.objects[self.count] = hittable;
    self.count += 1;
}

pub fn hit(self: *const World, ray: *const Ray, length_minmax: Interval) ?HitRecord {
    var record: ?HitRecord = null;
    var closest = length_minmax.max;

    for (self.objects[0..self.count]) |object| {
        const did_hit = object.hit(ray, Interval.new(length_minmax.min, closest));
        if (did_hit) |hit_info| {
            record = hit_info;
            closest = hit_info.t;
        }
    }

    return record;
}

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

    pub fn hit(self: *const Hittable, ray: *const Ray, length_minmax: Interval) ?HitRecord {
        return switch (self.*) {
            .sphere => |sphere| sphere.hit(ray, length_minmax),
        };
    }
};
