const Renderer = @import("renderer.zig").Renderer;
const cnst = @import("constants.zig");
const c = @import("cimport.zig").c;
const Input = @import("input.zig").Input;
const Ship = @import("ship.zig").Ship;
const shipmod = @import("ship.zig");

pub const Game = struct {
    renderer: Renderer,
    input: Input,

    ship: Ship,

    pub fn init(renderer: Renderer) Game {
        const g = Game{
            .renderer = renderer,
            .input = .{},
            .ship = Ship.init(),
        };
        return g;
    }

    pub fn update(self: *Game, dt: f32, window: ?*c.GLFWwindow) void {
        self.input.poll(window);
        self.ship.update(dt, self.input);
    }

    pub fn render(self: *Game) void {
        self.renderer.beginFrame();
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
