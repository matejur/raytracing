const Pos3 = @import("math/Pos3.zig");
const Color = @import("math/Color.zig");

pub const Texture = union(enum) {
    solid: SolidColor,
    checker: CheckerTexture,

    pub fn value(self: *const Texture, u: f32, v: f32, world_pos: Pos3) Color {
        return switch (self.*) {
            .solid => |s| s.value(u, v, world_pos),
            .checker => |c| c.value(u, v, world_pos),
        };
    }
};

pub const SolidColor = struct {
    albedo: Color,

    pub fn new(albedo: Color) Texture {
        return .{ .solid = .{ .albedo = albedo } };
    }

    pub fn value(self: *const SolidColor, u: f32, v: f32, world_pos: Pos3) Color {
        _ = u;
        _ = v;
        _ = world_pos;

        return self.albedo;
    }
};

pub const CheckerTexture = struct {
    even: *const Texture,
    odd: *const Texture,
    inv_scale: f32,

    pub fn new(even: *const Texture, odd: *const Texture, scale: f32) Texture {
        return .{ .checker = .{ .even = even, .odd = odd, .inv_scale = 1.0 / scale } };
    }

    pub fn value(self: *const CheckerTexture, u: f32, v: f32, world_pos: Pos3) Color {
        const xInteger = @floor(world_pos.x * self.inv_scale);
        const yInteger = @floor(world_pos.y * self.inv_scale);
        const zInteger = @floor(world_pos.z * self.inv_scale);

        const isEven = @mod(xInteger + yInteger + zInteger, 2) == 0;

        if (isEven) return self.even.value(u, v, world_pos);
        return self.odd.value(u, v, world_pos);
    }
};
