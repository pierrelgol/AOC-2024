const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var path_buffer: [std.fs.max_path_bytes]u8 = undefined;
    const cwd = std.fs.cwd();
    const hardcoded_input_path = cwd.realpath("./inputs/inputs.txt", path_buffer[0..]) catch unreachable;
    const inputs_path = b.option([]const u8, "inputs_path", "path to the input dataset") orelse hardcoded_input_path;
    const build_options = b.addOptions();
    build_options.addOption([]const u8, "path", inputs_path);

    const exe1 = b.addExecutable(.{
        .name = "day01-part1",
        .root_source_file = b.path("src/part1.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    exe1.root_module.addOptions("build_options", build_options);
    b.installArtifact(exe1);

    const exe2 = b.addExecutable(.{
        .name = "day01-part2",
        .root_source_file = b.path("src/part2.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    exe2.root_module.addOptions("build_options", build_options);
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
