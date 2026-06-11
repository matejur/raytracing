const std = @import("std");
const print = std.debug.print;

const raytracer = @import("raytracer");
const Pos3 = raytracer.Pos3;
const World = raytracer.World;
const Sphere = raytracer.Sphere;
const Camera = raytracer.Camera;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();

    const image_file = try cwd.createFile(io, "image.ppm", .{});
    defer image_file.close(io);

    var file_writer = image_file.writer(io, &.{});
    const writer = &file_writer.interface;

    var world = World{};
    try world.addObject(Sphere{ .center = Pos3.new(0, 0, -1), .radius = 0.5 });
    try world.addObject(Sphere{ .center = Pos3.new(0, -100.5, -1), .radius = 100 });

    const camera = Camera.create(.{ .image_width = 400 });
    try camera.render(&world, writer);
}
