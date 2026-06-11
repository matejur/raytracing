const std = @import("std");
const print = std.debug.print;

const World = @import("World.zig");
const Ray = @import("Ray.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");
const Color = @import("math/Color.zig");

const rand = @import("utility.zig");

const Camera = @This();

const CameraParameters = struct {
    aspect_ratio: f32 = 16.0 / 9.0,
    image_width: u32 = 400,
    samples_per_pixel: u32 = 10,
    max_bounces: u32 = 10,
};

image_width: u32,
image_height: u32,
center: Pos3,
first_pixel_loc: Pos3,
pixel_delta_u: Vec3,
pixel_delta_v: Vec3,
samples_per_pixel: u32,
pixel_samples_scale: f32,
max_bounces: u32,

pub fn create(parameters: CameraParameters) Camera {
    const aspect = parameters.aspect_ratio;
    const image_width = parameters.image_width;
    const image_height: u32 = @max(1, @as(u32, @floor(@as(f32, @floatFromInt(image_width)) / aspect)));

    const focal_length = 1.0;
    const viewport_height: f32 = 2.0;
    const viewport_width: f32 = viewport_height * (@as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height)));
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

    return .{
        .center = camera_center,
        .first_pixel_loc = first_pixel_loc,
        .image_height = image_height,
        .image_width = image_width,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .samples_per_pixel = parameters.samples_per_pixel,
        .pixel_samples_scale = 1.0 / @as(f32, @floatFromInt(parameters.samples_per_pixel)),
        .max_bounces = parameters.max_bounces,
    };
}

pub fn render(self: *const Camera, world: *const World, writer: *std.Io.Writer) !void {
    _ = try writer.print("P6\n{} {}\n255\n", .{ self.image_width, self.image_height });
    for (0..self.image_height) |j| {
        if (j % 100 == 0)
            print("\rScanlines remaining: {}", .{self.image_height - j});

        for (0..self.image_width) |i| {
            var color = Color.zero();

            for (0..self.samples_per_pixel) |_| {
                const ray = get_ray(self, i, j);
                color = color.add(ray.color(world, self.max_bounces));
            }

            color = color.scale(self.pixel_samples_scale);
            try color.write_color(writer);
        }
    }

    print("\rDone!                      \n", .{});
}

fn get_ray(self: *const Camera, i: usize, j: usize) Ray {
    const pixel_loc = self.first_pixel_loc
        .addVec(self.pixel_delta_u.scale(rand.random() - 0.5 + @as(f32, @floatFromInt(i))))
        .addVec(self.pixel_delta_v.scale(rand.random() - 0.5 + @as(f32, @floatFromInt(j))));

    return Ray.new(self.center, pixel_loc.sub(self.center));
}
