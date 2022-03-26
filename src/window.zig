const std = @import("std");
const SDL = @import("sdl2");
const Renderer = @import("renderer.zig").Renderer;

pub const Window = struct {
    sdlWindow: SDL.Window = undefined,
    sdlRenderer: SDL.Renderer = undefined,

    renderer: *Renderer = undefined,

    outputTexture: SDL.Texture = undefined,
    outputTextureRect: SDL.Rectangle = undefined,
    outputTextureInfo: SDL.Texture.Info = undefined,

    outputPixelBuffer: []u8 = undefined,

    inMainLoop: bool = false,

    pub fn init(self: *Window, width: usize, height: usize) !void {
        self.sdlWindow = try SDL.createWindow(
            "@eilume - Zig Simple Raytracer",
            .{ .centered = {} },
            .{ .centered = {} },
            width,
            height,
            .{ .shown = true },
        );

        self.sdlRenderer = try SDL.createRenderer(
            self.sdlWindow,
            null,
            .{ .accelerated = true },
        );

        self.outputTexture = try SDL.createTexture(self.sdlRenderer, SDL.PixelFormatEnum.rgba8888, SDL.Texture.Access.streaming, width, height);
        self.outputTextureRect = SDL.Rectangle{ .x = 0, .y = 0, .width = @intCast(c_int, width), .height = @intCast(c_int, height) };
        self.outputTextureInfo = try self.outputTexture.query();
    }

    pub fn setOutputPixelBuffer(self: *Window, outputPixelBuffer: []u8) !void {
        self.outputPixelBuffer = outputPixelBuffer;
    }

    pub fn mainLoop(self: *Window) !void {
        self.inMainLoop = true;

        while (self.inMainLoop) {
            try self.pollInput();

            try self.renderer.render();

            try self.update();
        }

        try self.cleanup();
    }

    pub fn cleanup(self: *Window) !void {
        self.outputTexture.destroy();
        self.sdlRenderer.destroy();
        self.sdlWindow.destroy();
    }

    fn pollInput(self: *Window) !void {
        while (SDL.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    self.inMainLoop = false;
                    break;
                },
                else => {},
            }
        }
    }

    fn update(self: *Window) !void {
        try self.sdlRenderer.setColorRGBA(0, 0, 0, 255);
        try self.sdlRenderer.clear();

        try self.updateTexture();
        try self.sdlRenderer.copy(self.outputTexture, null, self.outputTextureRect);

        self.sdlRenderer.present();
    }

    fn updateTexture(self: *Window) !void {
        var pixels = try self.outputTexture.lock(null);

        var index: usize = 0;
        while (index < self.outputPixelBuffer.len) : (index += 1) {
            pixels.pixels[index] = self.outputPixelBuffer[index];
        }

        // TODO: try doing a memory copy or set pointer
        // This doesn't work???
        // pixels.pixels = self.outputPixelBuffer.ptr;

        pixels.release();
    }
};
