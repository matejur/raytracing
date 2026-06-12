const std = @import("std");
const print = std.debug.print;

const raytracer = @import("raytracer");
const Pos3 = raytracer.Pos3;
const Color = raytracer.Color;
const World = raytracer.World;
const Sphere = raytracer.Sphere;
const Camera = raytracer.Camera;
const Lambertian = raytracer.Lambertian;
const Metal = raytracer.Metal;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();

    const image_file = try cwd.createFile(io, "image.ppm", .{});
    defer image_file.close(io);

    var file_writer = image_file.writer(io, &.{});
    const writer = &file_writer.interface;

    const material_ground = Lambertian.new(Color.new(0.8, 0.8, 0.0));
    const material_center = Lambertian.new(Color.new(0.1, 0.2, 0.5));
    const material_left = Metal.new(Color.new(0.8, 0.8, 0.8), 0.3);
    const material_right = Metal.new(Color.new(0.8, 0.6, 0.2), 1.0);

    var world = World{};
    try world.addObject(Sphere{ .center = Pos3.new(0, -100.5, -1), .radius = 100, .material = &material_ground });
    try world.addObject(Sphere{ .center = Pos3.new(0, 0, -1.2), .radius = 0.5, .material = &material_center });
    try world.addObject(Sphere{ .center = Pos3.new(-1, 0, -1.0), .radius = 0.5, .material = &material_left });
    try world.addObject(Sphere{ .center = Pos3.new(1, 0, -1.0), .radius = 0.5, .material = &material_right });

    const camera = Camera.create(.{
        .samples_per_pixel = 25,
        .image_width = 200,
        .max_bounces = 8,
    });
    try camera.render(&world, writer);
}
