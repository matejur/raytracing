const std = @import("std");
const print = std.debug.print;

const Ray = @import("Ray.zig");
const Scene = @import("Scene.zig");
const Pos3 = @import("math/Pos3.zig");
const Vec3 = @import("math/Vec3.zig");
const Color = @import("math/Color.zig");
const utils = @import("utility.zig");

const Camera = @This();

const CameraParameters = struct {
    aspect_ratio: f32 = 16.0 / 9.0,
    image_width: u32 = 400,
    samples_per_pixel: u32 = 10,
    max_bounces: u32 = 10,
    vfov: f32 = 90,
    lookfrom: Pos3 = Pos3.new(0, 0, 0),
    lookat: Pos3 = Pos3.new(0, 0, -1),
    vecup: Vec3 = Vec3.new(0, 1, 0),
    defocus_angle: f32 = 0,
    focus_dist: f32 = 10,
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
defocus_disk_u: Vec3,
defocus_disk_v: Vec3,
defocus_angle: f32,

pub fn create(params: CameraParameters) Camera {
    const aspect = params.aspect_ratio;
    const image_width = params.image_width;
    const image_height: u32 = @max(1, @as(u32, @floor(@as(f32, @floatFromInt(image_width)) / aspect)));

    const theta = utils.degree_to_rad(params.vfov);
    const h = @tan(theta / 2);
    const viewport_height: f32 = 2 * h * params.focus_dist;
    const viewport_width: f32 = viewport_height * (@as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height)));

    const w = params.lookfrom.sub(params.lookat).normalize();
    const u = params.vecup.cross(w).normalize();
    const v = w.cross(u);

    const viewport_u = u.scale(viewport_width);
    const viewport_v = v.neg().scale(viewport_height);

    const pixel_delta_u = viewport_u.scale(1 / @as(f32, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.scale(1 / @as(f32, @floatFromInt(image_height)));

    const viewport_upper_left = params.lookfrom
        .subVec(w.scale(params.focus_dist))
        .subVec(viewport_u.scale(0.5))
        .subVec(viewport_v.scale(0.5));
    const first_pixel_loc = viewport_upper_left
        .addVec(pixel_delta_u.add(pixel_delta_v).scale(0.5));

    const defocus_radius = params.focus_dist * @tan(utils.degree_to_rad(params.defocus_angle / 2));
    const defocus_disk_u = u.scale(defocus_radius);
    const defocus_disk_v = v.scale(defocus_radius);

    return .{
        .center = params.lookfrom,
        .first_pixel_loc = first_pixel_loc,
        .image_height = image_height,
        .image_width = image_width,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .samples_per_pixel = params.samples_per_pixel,
        .pixel_samples_scale = 1.0 / @as(f32, @floatFromInt(params.samples_per_pixel)),
        .max_bounces = params.max_bounces,
        .defocus_disk_u = defocus_disk_u,
        .defocus_disk_v = defocus_disk_v,
        .defocus_angle = params.defocus_angle,
    };
}

pub fn render(self: *const Camera, scene: *const Scene, writer: *std.Io.Writer) !void {
    _ = try writer.print("P6\n{} {}\n255\n", .{ self.image_width, self.image_height });
    for (0..self.image_height) |j| {
        print("\rScanlines remaining: {d:>4}", .{self.image_height - j});

        for (0..self.image_width) |i| {
            var color = Color.zero();

            for (0..self.samples_per_pixel) |_| {
                const ray = self.get_ray(i, j);
                color = color.add(ray.color(scene, self.max_bounces));
            }

            color = color.scale(self.pixel_samples_scale);
            try color.write_color(writer);
        }
    }

    print("\rDone!                      \n", .{});
}

fn get_ray(self: *const Camera, i: usize, j: usize) Ray {
    const pixel_loc = self.first_pixel_loc
        .addVec(self.pixel_delta_u.scale(utils.random() - 0.5 + @as(f32, @floatFromInt(i))))
        .addVec(self.pixel_delta_v.scale(utils.random() - 0.5 + @as(f32, @floatFromInt(j))));

    const ray_origin = if (self.defocus_angle <= 0) self.center else self.defocus_disk_sample();
    const ray_dir = pixel_loc.sub(ray_origin);
    const ray_time = utils.random();

    return .{
        .orig = ray_origin,
        .dir = ray_dir,
        .t = ray_time,
    };
}

fn defocus_disk_sample(self: *const Camera) Pos3 {
    const p = Vec3.random_in_unit_disk();
    return self.center
        .addVec(self.defocus_disk_u.scale(p.x))
        .addVec(self.defocus_disk_v.scale(p.y));
}
