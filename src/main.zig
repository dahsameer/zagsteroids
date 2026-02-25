const std = @import("std");

const c = @import("cimport.zig").c;
const cnst = @import("constants.zig");
const Renderer = @import("renderer.zig").Renderer;
const Game = @import("game.zig").Game;

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW Error {}: {s}\n", .{ err, description });
}

fn framebuffer_size_callback(_: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    c.glViewport(0, 0, width, height);
}

pub fn main() !void {
    // setting a callback for error in glfw
    _ = c.glfwSetErrorCallback(errorCallback);

    // glfw: initialize and configure
    if (c.glfwInit() == c.GLFW_FALSE) {
        std.debug.print("Failed to initialize GLFW\n", .{});
        return error.GLFWInitFailed;
    }
    defer c.glfwTerminate();
    defer std.debug.print("Goodbye!\n", .{});

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);

    // glfw window creation
    const window = c.glfwCreateWindow(
        @intFromFloat(cnst.SCREEN_WIDTH),
        @intFromFloat(cnst.SCREEN_HEIGHT),
        "Zagsteroids",
        null,
        null,
    );
    if (window == null) {
        std.debug.print("Failed to create GLFW window\n", .{});
        return error.WindowCreationFailed;
    }

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);

    // glad: load all opengl function pointers
    std.debug.print("Initializing GLAD...\n", .{});
    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.GLADInitFailed;
    }

    const version = c.glGetString(c.GL_VERSION);
    if (version != null) {
        std.debug.print("OpenGL Version: {s}\n", .{version});
    }

    std.debug.print("Window created successfully! Press ESC or close window to exit.\n", .{});

    c.glViewport(0, 0, cnst.SCREEN_WIDTH, cnst.SCREEN_HEIGHT);
    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    c.glEnable(c.GL_PROGRAM_POINT_SIZE);
    c.glPointSize(3.0);

    const renderer = try Renderer.init();
    defer renderer.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leak = gpa.deinit();
        if (leak == std.heap.Check.leak) {
            std.debug.print("Memory leak detected: {d} bytes\n", .{leak});
        }
    }
    const allocator = gpa.allocator();

    var game = try Game.init(renderer, allocator);
    defer game.deinit(allocator);
    var last_time: f64 = c.glfwGetTime();

    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
            c.glfwSetWindowShouldClose(window, c.GLFW_TRUE);
        }

        const now = c.glfwGetTime();
        const dt: f32 = @floatCast(now - last_time);
        last_time = now;

        try game.update(allocator, dt, window);
        game.render();

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}
