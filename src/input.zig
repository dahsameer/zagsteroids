const c = @import("cimport.zig").c;

pub const Input = struct {
    left: bool = false,
    right: bool = false,
    thrust: bool = false,
    shoot: bool = false,

    pub fn poll(self: *Input, window: ?*c.GLFWwindow) void {
        self.left = c.glfwGetKey(window, c.GLFW_KEY_LEFT) == c.GLFW_PRESS;
        self.right = c.glfwGetKey(window, c.GLFW_KEY_RIGHT) == c.GLFW_PRESS;
        self.thrust = c.glfwGetKey(window, c.GLFW_KEY_UP) == c.GLFW_PRESS;
        self.shoot = c.glfwGetKey(window, c.GLFW_KEY_SPACE) == c.GLFW_PRESS;
    }
};
