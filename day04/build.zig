const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe1 = b.addExecutable(.{
        .name = "day04-part1",
        .root_source_file = b.path("src/part1.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    b.installArtifact(exe1);

    const exe2 = b.addExecutable(.{
        .name = "day04-part2",
        .root_source_file = b.path("src/part2.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    b.installArtifact(exe2);

    const run_cmd1 = b.addRunArtifact(exe1);
    const run_cmd2 = b.addRunArtifact(exe2);
    run_cmd1.step.dependOn(b.getInstallStep());
    run_cmd2.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd1.addArgs(args);
        run_cmd2.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd1.step);
    run_step.dependOn(&run_cmd2.step);
}
