const std = @import("std");

const BvhNode = @import("bvh.zig").BvhNode;

const Ray = @import("Ray.zig");
const Hittable = Ray.Hittable;
const HitRecord = Ray.HitRecord;

const Interval = @import("math/Interval.zig");
const Sphere = @import("primitives/Sphere.zig");

const Scene = @This();

const max_objects = 512;

objects: [max_objects]Hittable = undefined,
count: usize = 0,
bvh: ?*Hittable = null,

const WorldError = error{Full};

pub fn addObject(self: *Scene, object: anytype) WorldError!void {
    if (self.count >= max_objects) return WorldError.Full;

    const T = @TypeOf(object);
    const hittable = switch (T) {
        Sphere => Hittable{ .sphere = object },
        else => @compileError(@typeName(T) ++ " can't be added to the world!"),
    };

    self.objects[self.count] = hittable;
    self.count += 1;
}

pub fn construct_bvh(self: *Scene, alloc: std.mem.Allocator) !void {
    self.bvh = try BvhNode.construct(self.objects[0..self.count], alloc);
}

pub fn hit(self: *const Scene, ray: *const Ray, length_minmax: Interval) ?HitRecord {
    if (self.bvh) |bvh| {
        return bvh.hit(ray, length_minmax);
    }

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
