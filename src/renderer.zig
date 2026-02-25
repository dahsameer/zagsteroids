const std = @import("std");
const c = @import("cimport.zig").c;
const cnst = @import("constants.zig");
const m = @import("math.zig");

const Uniforms = struct {
    translation: c_int,
    rotation: c_int,
    resolution: c_int,
    scale: c_int,
    color: c_int,
};

pub const Renderer = struct {
    program: c_uint,
    vao: c_uint,
    vbo: c_uint,
    uni: Uniforms,

    pub fn init() !Renderer {
        const vertexShaderSource: [*c]const u8 = @embedFile("resources/vert.glsl");
        const fragmentShaderSource: [*c]const u8 = @embedFile("resources/frag.glsl");
        const program = try compileProgram(vertexShaderSource, fragmentShaderSource);

        var vao: c_uint = 0;
        var vbo: c_uint = 0;
        c.glGenVertexArrays(1, &vao);
        c.glGenBuffers(1, &vbo);

        c.glBindVertexArray(vao);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glVertexAttribPointer(0, 2, c.GL_FLOAT, c.GL_FALSE, 2 * @sizeOf(f32), @ptrFromInt(0));
        c.glEnableVertexAttribArray(0);
        c.glBindVertexArray(0);

        const uni = Uniforms{
            .translation = c.glGetUniformLocation(program, "uTranslation"),
            .rotation = c.glGetUniformLocation(program, "uRotation"),
            .resolution = c.glGetUniformLocation(program, "uResolution"),
            .scale = c.glGetUniformLocation(program, "uScale"),
            .color = c.glGetUniformLocation(program, "uColor"),
        };

        return .{ .program = program, .vao = vao, .vbo = vbo, .uni = uni };
    }

    pub fn deinit(self: Renderer) void {
        c.glDeleteProgram(self.program);
        c.glDeleteVertexArrays(1, &self.vao);
        c.glDeleteBuffers(1, &self.vbo);
    }

    pub fn beginFrame(_: Renderer) void {
        c.glClearColor(0.0, 0.0, 0.05, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn draw(
        self: Renderer,
        points: []const [2]f32,
        pos: m.Vec2,
        rotation: f32,
        scale: f32,
        color: [4]f32,
        mode: c_uint,
    ) void {
        c.glUseProgram(self.program);
        c.glBindVertexArray(self.vao);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo);

        c.glBufferData(
            c.GL_ARRAY_BUFFER,
            @intCast(points.len * @sizeOf([2]f32)),
            points.ptr,
            c.GL_DYNAMIC_DRAW,
        );

        c.glUniform2f(self.uni.translation, pos.x, pos.y);
        c.glUniform1f(self.uni.rotation, rotation);
        c.glUniform2f(self.uni.resolution, cnst.SCREEN_WIDTH, cnst.SCREEN_HEIGHT);
        c.glUniform1f(self.uni.scale, scale);
        c.glUniform4f(self.uni.color, color[0], color[1], color[2], color[3]);

        c.glDrawArrays(mode, 0, @intCast(points.len));
    }
};

fn compileShader(kind: c_uint, src: [*c]const u8) !c_uint {
    const shader = c.glCreateShader(kind);
    c.glShaderSource(shader, 1, &src, null);
    c.glCompileShader(shader);

    var ok: c_int = 0;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &ok);
    if (ok == c.GL_FALSE) {
        var log: [512:0]u8 = undefined;
        c.glGetShaderInfoLog(shader, 512, null, @ptrCast(&log));
        std.debug.print("Shader compile error: {s}\n", .{log});
        c.glDeleteShader(shader);
        return error.ShaderCompileFailed;
    }
    return shader;
}

fn compileProgram(vert_src: [*c]const u8, frag_src: [*c]const u8) !c_uint {
    const vert = try compileShader(c.GL_VERTEX_SHADER, vert_src);
    defer c.glDeleteShader(vert);
    const frag = try compileShader(c.GL_FRAGMENT_SHADER, frag_src);
    defer c.glDeleteShader(frag);

    const program = c.glCreateProgram();
    c.glAttachShader(program, vert);
    c.glAttachShader(program, frag);
    c.glLinkProgram(program);

    var ok: c_int = 0;
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &ok);
    if (ok == c.GL_FALSE) {
        var log: [512:0]u8 = undefined;
        c.glGetProgramInfoLog(program, 512, null, @ptrCast(&log));
        std.debug.print("Program link error: {s}\n", .{log});
        c.glDeleteProgram(program);
        return error.ProgramLinkFailed;
    }
    return program;
}
