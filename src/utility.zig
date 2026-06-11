const std = @import("std");

var prng = std.Random.DefaultPrng.init(42);
var rng = prng.random();

pub fn random() f32 {
    return rng.float(f32);
}

pub fn random_minmax(min: f32, max: f32) f32 {
    return min + (max - min) * random();
}
