const std = @import("std");
const Interval = @import("math/Interval.zig");
const Pos3 = @import("math/Pos3.zig");
const Ray = @import("Ray.zig");
const Hittable = Ray.Hittable;
const HitRecord = Ray.HitRecord;

pub const BvhNode = struct {
    left: *const Hittable,
    right: *const Hittable,
    bbox: AABB,

    pub fn construct(objects: []Hittable, alloc: std.mem.Allocator) !*Hittable {
        var node: BvhNode = undefined;
        node.bbox = AABB.empty;
        for (objects) |obj| {
            node.bbox = node.bbox.combine(obj.bounding_box());
        }

        if (objects.len == 1) {
            node.left = &objects[0];
            node.right = &objects[0];
        } else if (objects.len == 2) {
            node.left = &objects[0];
            node.right = &objects[1];
        } else {
            const split_axis = node.bbox.longest_axis();

            std.mem.sort(Hittable, objects, split_axis, compare_bbox);

            const mid = objects.len / 2;
            node.left = try BvhNode.construct(objects[0..mid], alloc);
            node.right = try BvhNode.construct(objects[mid..], alloc);
        }

        const hittable = try alloc.create(Hittable);
        hittable.* = .{ .bvh = node };

        return hittable;
    }

    fn compare_bbox(axis: Axis, h1: Hittable, h2: Hittable) bool {
        const bbox1 = h1.bounding_box();
        const bbox2 = h2.bounding_box();

        switch (axis) {
            .X => return bbox1.x.min < bbox2.x.min,
            .Y => return bbox1.y.min < bbox2.y.min,
            .Z => return bbox1.z.min < bbox2.z.min,
        }
    }

    pub fn hit(self: *const BvhNode, ray: *const Ray, length_minmax: Interval) ?HitRecord {
        if (!self.bbox.hit(ray, length_minmax))
            return null;

        var interval = length_minmax;

        const left_hit = self.left.hit(ray, interval);
        if (left_hit) |h| {
            interval.max = h.t;
        }

        const right_hit = self.right.hit(ray, interval);

        if (right_hit) |h| return h;
        if (left_hit) |h| return h;

        return null;
    }
};

const Axis = enum { X, Y, Z };

pub const AABB = struct {
    x: Interval,
    y: Interval,
    z: Interval,

    pub const empty = AABB{
        .x = Interval.empty,
        .y = Interval.empty,
        .z = Interval.empty,
    };

    pub const universe = AABB{
        .x = Interval.universe,
        .y = Interval.universe,
        .z = Interval.universe,
    };

    pub fn from_points(p1: Pos3, p2: Pos3) AABB {
        return .{
            .x = .{ .min = @min(p1.x, p2.x), .max = @max(p1.x, p2.x) },
            .y = .{ .min = @min(p1.y, p2.y), .max = @max(p1.y, p2.y) },
            .z = .{ .min = @min(p1.z, p2.z), .max = @max(p1.z, p2.z) },
        };
    }

    pub fn combine(self: AABB, other: AABB) AABB {
        return .{
            .x = self.x.merge(other.x),
            .y = self.y.merge(other.y),
            .z = self.z.merge(other.z),
        };
    }

    pub fn longest_axis(self: AABB) Axis {
        if (self.x.size() > self.y.size()) {
            return if (self.x.size() > self.z.size()) .X else .Z;
        }
        return if (self.y.size() > self.z.size()) .Y else .Z;
    }

    pub fn hit(self: AABB, ray: *const Ray, length_minmax: Interval) bool {
        const ray_origin = ray.orig;
        const ray_dir = ray.dir;

        var interval = length_minmax;
        inline for (@typeInfo(AABB).@"struct".fields) |field| {
            const ax = @field(self, field.name);
            const inv = 1.0 / @field(ray_dir, field.name);

            const t0 = (ax.min - @field(ray_origin, field.name)) * inv;
            const t1 = (ax.max - @field(ray_origin, field.name)) * inv;

            if (t0 < t1) {
                if (t0 > interval.min) interval.min = t0;
                if (t1 < interval.max) interval.max = t1;
            } else {
                if (t1 > interval.min) interval.min = t1;
                if (t0 < interval.max) interval.max = t0;
            }

            if (interval.max <= interval.min) return false;
        }

        return true;
    }
};
