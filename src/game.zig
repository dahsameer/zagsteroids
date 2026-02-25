const Renderer = @import("renderer.zig").Renderer;
const cnst = @import("constants.zig");
const c = @import("cimport.zig").c;
const Input = @import("input.zig").Input;
const Ship = @import("ship.zig").Ship;
const Bullet = @import("bullet.zig").Bullet;
const shipmod = @import("ship.zig");
const bulletsmod = @import("bullet.zig");

const std = @import("std");

pub const Game = struct {
    renderer: Renderer,
    input: Input,
    ship: Ship,
    bullets: std.ArrayList(Bullet),
    shoot_cooldown: f32,

    pub fn init(renderer: Renderer, allocator: std.mem.Allocator) !Game {
        const g = Game{
            .renderer = renderer,
            .input = .{},
            .ship = Ship.init(),
            .bullets = try std.ArrayList(Bullet).initCapacity(allocator, 10),
            .shoot_cooldown = 0.0,
        };
        return g;
    }

    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        self.bullets.deinit(allocator);
    }

    pub fn update(self: *Game, allocator: std.mem.Allocator, dt: f32, window: ?*c.GLFWwindow) !void {
        self.input.poll(window);
        self.ship.update(dt, self.input);
        if (self.input.shoot and self.shoot_cooldown <= 0.0) {
            const bullet = Bullet.init(self.ship.pos, self.ship.vel, self.ship.angle);
            _ = try self.bullets.append(allocator, bullet);
            self.shoot_cooldown = 0.1;
        } else if (self.shoot_cooldown > 0.0) {
            self.shoot_cooldown -= dt;
        }

        for (self.bullets.items) |*bullet| {
            bullet.update(dt);
        }

        var i: usize = self.bullets.items.len;
        while (i > 0) {
            i -= 1;
            if (self.bullets.items[i].dead()) {
                self.bullets.items[i] = self.bullets.items[self.bullets.items.len - 1];
                _ = self.bullets.pop();
            }
        }
    }

    pub fn render(self: *Game) void {
        self.renderer.beginFrame();
        for (self.bullets.items) |bullet| {
            self.renderer.draw(
                &bulletsmod.SHAPE,
                bullet.pos,
                0.0,
                1.0,
                .{ 1.0, 1.0, 0.0, 1.0 },
                c.GL_LINE_LOOP,
            );
        }
        self.renderer.draw(
            &shipmod.SHAPE,
            self.ship.pos,
            self.ship.angle,
            1.0,
            .{ 1.0, 1.0, 1.0, 1.0 },
            c.GL_LINE_LOOP,
        );
        if (self.input.thrust) {
            self.renderer.draw(
                &shipmod.FLAME_SHAPE,
                self.ship.pos,
                self.ship.angle,
                1.0,
                .{ 1.0, 0.5, 0.0, 1.0 },
                c.GL_TRIANGLES,
            );
        }
    }
};
