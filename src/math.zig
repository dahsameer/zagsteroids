const std = @import("std");
const cnst = @import("constants.zig");

pub const Vec2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn sub(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn scale(self: Vec2, factor: f32) Vec2 {
        return Vec2{
            .x = self.x * factor,
            .y = self.y * factor,
        };
    }

    pub fn length(self: Vec2) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }
};

pub fn fromAngle(angle: f32) Vec2 {
    return Vec2{
        .x = std.math.sin(angle),
        .y = -std.math.cos(angle),
    };
}

pub fn wrap(v: Vec2) Vec2 {
    return .{ .x = @mod(
        v.x + cnst.SCREEN_WIDTH * 10,
        cnst.SCREEN_WIDTH,
    ), .y = @mod(
        v.y + cnst.SCREEN_HEIGHT * 10,
        cnst.SCREEN_HEIGHT,
    ) };
}
