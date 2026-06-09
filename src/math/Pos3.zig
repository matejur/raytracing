const Common = @import("common.zig").Common;
const Vec3 = @import("Vec3.zig");

x: f32,
y: f32,
z: f32,

const Pos3 = @This();

const common = Common(Pos3);

pub const new = common.new;
pub const zero = common.zero;
pub const splat = common.splat;
pub const sub = common.sub(Pos3, Pos3, Vec3);
pub const subVec = common.sub(Pos3, Vec3, Pos3);
pub const addVec = common.add(Pos3, Vec3, Pos3);
