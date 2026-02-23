const cnst = @import("constants.zig");
const m = @import("math.zig");
const Vec2 = m.Vec2;
const Input = @import("input.zig").Input;

const TURN_SPEED: f32 = 2.0;
const THRUST_FORCE: f32 = 200.0;
const MAX_SPEED: f32 = 500.0;
const DAMPING: f32 = 0.99;

pub const SHAPE = [_][2]f32{
    .{ 0, -16 },
    .{ 11, 12 },
    .{ 5, 7 },
    .{ 0, 10 },
    .{ -5, 7 },
    .{ -11, 12 },
};

pub const FLAME_SHAPE = [_][2]f32{
    .{ -4, 10 },
    .{ 0, 22 },
    .{ 4, 10 },
};

pub const Ship = struct {
    pos: Vec2,
    vel: Vec2,
    angle: f32,

    pub fn init() Ship {
        return .{
            .pos = .{ .x = cnst.SCREEN_WIDTH / 2, .y = cnst.SCREEN_HEIGHT / 2 },
            .vel = .{},
            .angle = 0,
        };
    }

    pub fn update(self: *Ship, dt: f32, input: Input) void {
        if (input.left) self.angle -= TURN_SPEED * dt;
        if (input.right) self.angle += TURN_SPEED * dt;

        if (input.thrust) {
            const dir = m.fromAngle(self.angle);
            self.vel = self.vel.add(dir.scale(THRUST_FORCE * dt));

            const spd = self.vel.length();
            if (spd > MAX_SPEED) {
                self.vel = self.vel.scale(MAX_SPEED / spd);
            }
        }

        self.vel = self.vel.scale(DAMPING);
        self.pos = m.wrap(self.pos.add(self.vel.scale(dt)));
    }
};
