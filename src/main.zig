const std = @import("std");
const print = std.debug.print;

const Color = @import("math/Color.zig").Color;
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");

const Ray = @import("Ray.zig");

const hittable = @import("objects/hittable.zig");
const World = hittable.World;
const Hittable = hittable.Hittable;

const Sphere = @import("objects/Sphere.zig");

const aspect: f32 = 16.0 / 9.0;
const image_width: i32 = 400;
const image_height: i32 = @max(1, @floor(image_width / aspect));

const focal_length = 1.0;
const viewport_height: f32 = 2.0;
const viewport_width: f32 = viewport_height * (@as(f32, image_width) / image_height);
const camera_center = Pos3.zero();

const viewport_u = Vec3.new(viewport_width, 0, 0);
const viewport_v = Vec3.new(0, -viewport_height, 0);

const pixel_delta_u = viewport_u.scale(1 / @as(f32, @floatFromInt(image_width)));
const pixel_delta_v = viewport_v.scale(1 / @as(f32, @floatFromInt(image_height)));

const viewport_upper_left = camera_center
    .subVec(.{ .x = 0, .y = 0, .z = focal_length })
    .subVec(viewport_u.scale(0.5))
    .subVec(viewport_v.scale(0.5));
const first_pixel_loc = viewport_upper_left
    .addVec(pixel_delta_u.add(pixel_delta_v).scale(0.5));

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();

    const image_file = try cwd.createFile(io, "image.ppm", .{});
    defer image_file.close(io);

    var file_writer = image_file.writer(io, &.{});
    const writer = &file_writer.interface;

    _ = try writer.print("P6\n{} {}\n255\n", .{ image_width, image_height });

    var world = World{
        .objects = &[_]Hittable{
            .{ .sphere = Sphere{ .center = Pos3.new(0, 0, -1), .radius = 0.5 } },
            .{ .sphere = Sphere{ .center = Pos3.new(0, -100.5, -1), .radius = 100 } },
        },
    };

    for (0..image_height) |j| {
        print("\rScanlines remaining: {}", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_center = first_pixel_loc
                .addVec(pixel_delta_u.scale(@floatFromInt(i)))
                .addVec(pixel_delta_v.scale(@floatFromInt(j)));
            const ray_dir = pixel_center.sub(camera_center);
            const ray = Ray.new(camera_center, ray_dir);

            const color = ray.color(&world);

            try color.write_color(writer);
        }
    }

    print("\rDone!                      \n", .{});
}
