const std = @import("std");
const print = std.debug.print;

pub const Color = @import("math/Color.zig");
pub const Pos3 = @import("math/Pos3.zig");
pub const Vec3 = @import("math/Vec3.zig");

pub const Sphere = @import("primitives/Sphere.zig");

pub const Camera = @import("Camera.zig");
pub const Scene = @import("Scene.zig");

const mat = @import("materials.zig");
pub const Material = mat.Material;
pub const Lambertian = mat.Lambertian;
pub const Metal = mat.Metal;
pub const Dielectric = mat.Dielectric;

const tex = @import("textures.zig");
pub const Texture = tex.Texture;
pub const SolidColor = tex.SolidColor;
pub const CheckerTexture = tex.CheckerTexture;

pub const utils = @import("utility.zig");

pub fn render(scene: Scene, camera: Camera, writer: *std.Io.Writer) !void {
    _ = try writer.print("P6\n{} {}\n255\n", .{ camera.image_width, camera.image_height });
    for (0..camera.image_height) |j| {
        print("\rScanlines remaining: {d:>4}", .{camera.image_height - j});

        for (0..camera.image_width) |i| {
            var color = Color.zero();

            for (0..camera.samples_per_pixel) |_| {
                const ray = camera.get_ray(i, j);
                color = color.add(ray.color(scene, camera.max_bounces));
            }

            color = color.scale(camera.pixel_samples_scale);
            try color.write_color(writer);
        }
    }

    print("\rDone!                      \n", .{});
}
