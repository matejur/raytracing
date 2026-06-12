const std = @import("std");
const print = std.debug.print;

const raytracer = @import("raytracer");
const Pos3 = raytracer.Pos3;
const Color = raytracer.Color;
const World = raytracer.World;
const Sphere = raytracer.Sphere;
const Camera = raytracer.Camera;
const Material = raytracer.Material;
const Lambertian = raytracer.Lambertian;
const Metal = raytracer.Metal;
const Dielectric = raytracer.Dielectric;
const utils = raytracer.utils;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();

    const image_file = try cwd.createFile(io, "image.ppm", .{});
    defer image_file.close(io);

    var file_writer = image_file.writer(io, &.{});
    const writer = &file_writer.interface;

    try scene1(writer);
}

fn scene1(writer: *std.Io.Writer) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var world = World{};

    const ground_mat = Lambertian.new(Color.new(0.5, 0.5, 0.5));
    try world.addObject(Sphere{
        .center = Pos3.new(0, -1000, 0),
        .radius = 1000,
        .material = &ground_mat,
    });

    var a: f32 = -10;
    while (a <= 10) : (a += 1) {
        var b: f32 = -10;
        while (b <= 10) : (b += 1) {
            const center = Pos3.new(
                a + 0.9 * utils.random(),
                0.2,
                b + 0.9 * utils.random(),
            );

            if (center.sub(Pos3.new(4, 0.2, 0)).length() > 0.9) {
                const choose_mat = utils.random();
                const mat: *Material = try allocator.create(Material);

                if (choose_mat < 0.8) {
                    mat.* = Lambertian.new(Color.random().mul(Color.random()));
                } else if (choose_mat < 0.95) {
                    mat.* = Metal.new(
                        Color.random_minmax(0.5, 1.0),
                        utils.random_minmax(0, 0.5),
                    );
                } else {
                    mat.* = Dielectric.new(1.5);
                }

                try world.addObject(Sphere{
                    .center = center,
                    .radius = 0.2,
                    .material = mat,
                });
            }
        }
    }

    try world.addObject(Sphere{
        .center = Pos3.new(0, 1, 0),
        .radius = 1.0,
        .material = &Dielectric.new(1.5),
    });

    try world.addObject(Sphere{
        .center = Pos3.new(-4, 1, 0),
        .radius = 1.0,
        .material = &Lambertian.new(Color.new(0.4, 0.2, 0.1)),
    });

    try world.addObject(Sphere{
        .center = Pos3.new(4, 1, 0),
        .radius = 1.0,
        .material = &Metal.new(Color.new(0.7, 0.6, 0.5), 0),
    });

    const camera = Camera.create(.{
        .samples_per_pixel = 200,
        .image_width = 800,
        .max_bounces = 10,
        .lookfrom = Pos3.new(13, 2, 3),
        .lookat = Pos3.new(0, 0, 0),
        .vfov = 20,
        .defocus_angle = 0.6,
        .focus_dist = 10,
    });

    try camera.render(&world, writer);
}
