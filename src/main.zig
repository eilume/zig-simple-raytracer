const std = @import("std");
const SDL = @import("sdl2");

const Window = @import("window.zig").Window;
const Renderer = @import("renderer.zig").Renderer;

pub fn main() !void {
    const width: usize = 1280;
    const height: usize = 720;

    var w: Window = .{};
    var r: Renderer = .{};

    w.renderer = &r;

    r.width = width;
    r.height = height;
    r.pixelDepth = 4;

    const allocator = std.heap.page_allocator;
    var pixelBuffer = try allocator.alloc(u8, width * height * 4);
    defer allocator.free(pixelBuffer);

    try r.setOutputPixelBuffer(pixelBuffer);
    try w.setOutputPixelBuffer(pixelBuffer);

    try w.init(width, height);

    try w.mainLoop();
}
