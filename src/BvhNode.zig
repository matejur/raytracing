const std = @import("std");

const World = @import("World.zig");
const Hittable = World.Hittable;
const HitRecord = World.HitRecord;

const AABB = @import("AABB.zig");
const Ray = @import("Ray.zig");
const Interval = @import("math/Interval.zig");
const utils = @import("utility.zig");

const BvhNode = @This();

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

        std.debug.assert(-1 < split_axis and split_axis < 3);
        if (split_axis == 0) std.mem.sort(Hittable, objects, .{}, compare_x);
        if (split_axis == 1) std.mem.sort(Hittable, objects, .{}, compare_y);
        if (split_axis == 2) std.mem.sort(Hittable, objects, .{}, compare_z);

        const mid = objects.len / 2;
        node.left = try BvhNode.construct(objects[0..mid], alloc);
        node.right = try BvhNode.construct(objects[mid..], alloc);
    }

    const hittable = try alloc.create(Hittable);
    hittable.* = .{ .bvh = node };

    return hittable;
}

fn compare_x(_: @TypeOf(.{}), h1: Hittable, h2: Hittable) bool {
    const interval1: Interval = h1.bounding_box().x;
    const interval2: Interval = h2.bounding_box().x;
    return interval1.min < interval2.min;
}
fn compare_y(_: @TypeOf(.{}), h1: Hittable, h2: Hittable) bool {
    const interval1: Interval = h1.bounding_box().y;
    const interval2: Interval = h2.bounding_box().y;
    return interval1.min < interval2.min;
}
fn compare_z(_: @TypeOf(.{}), h1: Hittable, h2: Hittable) bool {
    const interval1: Interval = h1.bounding_box().z;
    const interval2: Interval = h2.bounding_box().z;
    return interval1.min < interval2.min;
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
