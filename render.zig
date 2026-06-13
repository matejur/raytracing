const std = @import("std");
const print = std.debug.print;

const raytracer = @import("raytracer");
const Pos3 = raytracer.Pos3;
const Vec3 = raytracer.Vec3;
const Color = raytracer.Color;
const Sphere = raytracer.Sphere;
const Camera = raytracer.Camera;
const Material = raytracer.Material;
const Lambertian = raytracer.Lambertian;
const Metal = raytracer.Metal;
const Dielectric = raytracer.Dielectric;
const Scene = raytracer.Scene;
const utils = raytracer.utils;

const Options = struct {
    construct_bvh: bool = true,
    scene: u32 = 0,
};

fn parse_args(init: std.process.Init) Options {
    const args = init.minimal.args.vector;
    var options = Options{};

    var i: usize = 1;
    if (i < args.len) {
        if (std.fmt.parseInt(u32, std.mem.span(args[i]), 10)) |num| {
            options.scene = num;
            i += 1;
        } else |_| {} // Just skip if it's not an integer
    }

    while (i < args.len) : (i += 1) {
        const arg = std.mem.span(args[i]);

        if (std.mem.eql(u8, arg, "--no-bvh")) {
            options.construct_bvh = false;
            i += 1;
        } //else if (std.mem.eql(u8, arg, "--width")) {
        //     i += 1;
        //     if (i < args.len)
        //         width = std.fmt.parseInt(usize, args[i], 10) catch width;
        // }
    }

    return options;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();

    const image_file = try cwd.createFile(io, "image.ppm", .{});
    defer image_file.close(io);

    var file_writer = image_file.writer(io, &.{});
    const writer = &file_writer.interface;

    const allocator = init.arena.allocator();

    const options = parse_args(init);

    var scene, var camera = switch (options.scene) {
        0 => try test_scene(allocator),
        1 => try scene1(allocator),
        else => {
            std.debug.print("{} is not a valid scene number\n", .{options.scene});
            return;
        },
    };

    if (options.construct_bvh)
        try scene.construct_bvh(allocator);

    try camera.render(&scene, writer);
}

fn test_scene(alloc: std.mem.Allocator) !struct { Scene, Camera } {
    var scene = Scene{};

    const material = try alloc.create(Material);
    material.* = Lambertian.new(Color.new(0.5, 0.5, 0.5));
    try scene.addObject(Sphere.static(
        Pos3.new(-1, 0, 0),
        0.5,
        material,
    ));
    try scene.addObject(Sphere.static(
        Pos3.new(1, 0, 0),
        0.5,
        material,
    ));
    try scene.addObject(Sphere.static(
        Pos3.new(0, 0, 0),
        0.5,
        material,
    ));

    const camera = Camera.create(.{
        .samples_per_pixel = 25,
        .image_width = 400,
        .max_bounces = 10,
        .lookfrom = Pos3.new(0, 0, 3),
        .lookat = Pos3.new(0, 0, 0),
        .vfov = 20,
        .defocus_angle = 0.6,
        .focus_dist = 10,
    });

    return .{ scene, camera };
}

fn scene1(alloc: std.mem.Allocator) !struct { Scene, Camera } {
    var scene = Scene{};

    const ground_mat = try alloc.create(Material);
    ground_mat.* = Lambertian.new(Color.new(0.5, 0.5, 0.5));
    try scene.addObject(Sphere.static(
        Pos3.new(0, -1000, 0),
        1000,
        ground_mat,
    ));

    var a: f32 = -10;
    while (a <= 10) : (a += 1) {
        var b: f32 = -10;
        while (b <= 10) : (b += 1) {
            const center1 = Pos3.new(
                a + 0.9 * utils.random(),
                0.2,
                b + 0.9 * utils.random(),
            );

            if (center1.sub(Pos3.new(4, 0.2, 0)).length() > 0.9) {
                const choose_mat = utils.random();
                const mat: *Material = try alloc.create(Material);
                var center2: Pos3 = undefined;

                if (choose_mat < 0.8) {
                    mat.* = Lambertian.new(Color.random().mul(Color.random()));
                    center2 = center1.addVec(Vec3.new(0, utils.random_minmax(0, 0.5), 0));
                } else if (choose_mat < 0.95) {
                    mat.* = Metal.new(
                        Color.random_minmax(0.5, 1.0),
                        utils.random_minmax(0, 0.5),
                    );
                    center2 = center1;
                } else {
                    mat.* = Dielectric.new(1.5);
                    center2 = center1;
                }

                try scene.addObject(Sphere.moving(
                    center1,
                    center2,
                    0.2,
                    mat,
                ));
            }
        }
    }

    var mat = try alloc.create(Material);
    mat.* = Dielectric.new(1.5);
    try scene.addObject(Sphere.static(
        Pos3.new(0, 1, 0),
        1.0,
        mat,
    ));

    mat = try alloc.create(Material);
    mat.* = Lambertian.new(Color.new(0.4, 0.2, 0.1));
    try scene.addObject(Sphere.static(
        Pos3.new(-4, 1, 0),
        1.0,
        mat,
    ));

    mat = try alloc.create(Material);
    mat.* = Metal.new(Color.new(0.7, 0.6, 0.5), 0);
    try scene.addObject(Sphere.static(
        Pos3.new(4, 1, 0),
        1.0,
        mat,
    ));

    const camera = Camera.create(.{
        .samples_per_pixel = 100,
        .image_width = 400,
        .max_bounces = 50,
        .lookfrom = Pos3.new(13, 2, 3),
        .lookat = Pos3.new(0, 0, 0),
        .vfov = 20,
        .defocus_angle = 0.6,
        .focus_dist = 10,
    });

    return .{ scene, camera };
}
