const Vec2 = @import("math.zig").Vec2;
const m = @import("math.zig");

pub const SHAPE = [_][2]f32{
    .{ -1.5, -1.5 },
    .{ 1.5, -1.5 },
    .{ 1.5, 1.5 },
    .{ -1.5, 1.5 },
};

pub const Bullet = struct {
    pos: Vec2,
    speed: Vec2,
    life: f32,

    pub fn init(pos: Vec2, vel: Vec2, angle: f32) Bullet {
        const dir = Vec2{
            .x = @sin(angle),
            .y = -@cos(angle),
        };
        return Bullet{
            .pos = pos,
            .speed = vel.add(dir.scale(500)),
            .life = 2.0,
        };
    }

    pub fn update(self: *Bullet, dt: f32) void {
        self.life -= dt;
        self.pos = m.wrap(self.pos.add(self.speed.scale(dt)));
    }

    pub fn dead(self: *Bullet) bool {
        return self.life <= 0;
    }
};
