const std = @import("std");

pub const Renderer = struct {
    width: usize = undefined,
    height: usize = undefined,

    pixelDepth: u8 = undefined,

    outputPixelBuffer: []u8 = undefined,

    pub fn setOutputPixelBuffer(self: *Renderer, outputPixelBuffer: []u8) !void {
        self.outputPixelBuffer = outputPixelBuffer;
    }

    pub fn render(self: *Renderer) !void {
        try self.generateNoise();
    }

    fn generateNoise(self: *Renderer) !void {
        var x: usize = 0;
        var y: usize = 0;
        var value: u8 = 0;
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        var r = prng.random();

        while (y < self.height) : (y += 1) {
            while (x < self.width) : (x += 1) {
                value = r.intRangeAtMost(u8, 0, 255);
                self.outputPixelBuffer[(x * self.pixelDepth) + (y * self.width * self.pixelDepth) + 0] = 255;
                self.outputPixelBuffer[(x * self.pixelDepth) + (y * self.width * self.pixelDepth) + 1] = value;
                self.outputPixelBuffer[(x * self.pixelDepth) + (y * self.width * self.pixelDepth) + 2] = value;
                self.outputPixelBuffer[(x * self.pixelDepth) + (y * self.width * self.pixelDepth) + 3] = value;
            }
            x = 0;
        }
    }
};
