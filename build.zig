const std = @import("std");

var target: std.zig.CrossTarget = undefined;
var optimize: std.builtin.Mode = undefined;

fn addExample(b: *std.build.Builder, comptime name: []const u8, flags: ?[]const []const u8, sources: ?[]const []const u8, includes: ?[]const []const u8, exports: ?[]const []const u8) void {
    const lib = b.addSharedLibrary(.{
        .name = name,
        .root_source_file = .{ .path = "src/" ++ name ++ "/" ++ name ++ ".zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.install();
    lib.addIncludePath("src/" ++ name);
    //lib.export_symbol_names = {"getLeftBufPtr"};

    if (includes != null) {
        for (includes.?) |inc| {
            lib.addIncludePath(inc);
        }
    }
    if (flags != null and sources != null) {
        lib.addCSourceFiles(sources.?, flags.?);
    }

    if (exports != null) {
        lib.export_symbol_names = exports.?;
    }

    b.installFile("src/" ++ name ++ "/" ++ name ++ ".html", name ++ ".html");
}

pub fn build(b: *std.build.Builder) void {
    target = b.standardTargetOptions(.{ .default_target = .{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    } });
    optimize = b.standardOptimizeOption(.{});

    b.installFile("src/index.html", "index.html");
    b.installFile("src/pcm-processor.js", "pcm-processor.js");
    b.installFile("src/wasmpcm.js", "wasmpcm.js");
    b.installFile("src/ringbuf.js", "ringbuf.js");
    b.installFile("src/coi-serviceworker.js", "coi-serviceworker.js");
    b.installFile("src/unmute.js", "unmute.js");

    addExample(b, "sinetone", null, null, null, &.{
        "setSampleRate", "getLeftBufPtr", "getRightBufPtr",
        "setLeftFreq",   "setRightFreq",  "renderSoundQuantum",
    });

    addExample(b, "synth", null, null, null, &.{
        "noteOn",             "noteOff",
        "getLeftBufPtr",      "getRightBufPtr",
        "renderSoundQuantum",
    });

    addExample(b, "mod", &.{"-Wall"}, &.{"src/mod/pocketmod.c"}, null, &.{
        "setSampleRate", "getLeftBufPtr", "getRightBufPtr", "renderSoundQuantum",
    });

    addExample(b, "bat", &.{"-Wall"}, &.{"src/mod/pocketmod.c"}, null, &.{
        "keyevent",       "getGfxBufPtr",
        "setSampleRate",  "getLeftBufPtr",
        "getRightBufPtr", "renderSoundQuantum",
        "init",           "update",
        "renderGfx",
    });

    addExample(b, "doom", &.{ "-Wall", "-fno-sanitize=undefined" }, &.{
        "src/doom/puredoom/DOOM.c",     "src/doom/puredoom/PureDOOM.c", "src/doom/puredoom/am_map.c",
        "src/doom/puredoom/d_items.c",  "src/doom/puredoom/d_main.c",   "src/doom/puredoom/d_net.c",
        "src/doom/puredoom/doomdef.c",  "src/doom/puredoom/doomstat.c", "src/doom/puredoom/dstrings.c",
        "src/doom/puredoom/f_finale.c", "src/doom/puredoom/f_wipe.c",   "src/doom/puredoom/g_game.c",
        "src/doom/puredoom/hu_lib.c",   "src/doom/puredoom/hu_stuff.c", "src/doom/puredoom/i_net.c",
        "src/doom/puredoom/i_sound.c",  "src/doom/puredoom/i_system.c", "src/doom/puredoom/i_video.c",
        "src/doom/puredoom/info.c",     "src/doom/puredoom/m_argv.c",   "src/doom/puredoom/m_bbox.c",
        "src/doom/puredoom/m_cheat.c",  "src/doom/puredoom/m_fixed.c",  "src/doom/puredoom/m_menu.c",
        "src/doom/puredoom/m_misc.c",   "src/doom/puredoom/m_random.c", "src/doom/puredoom/m_swap.c",
        "src/doom/puredoom/p_ceilng.c", "src/doom/puredoom/p_doors.c",  "src/doom/puredoom/p_enemy.c",
        "src/doom/puredoom/p_floor.c",  "src/doom/puredoom/p_inter.c",  "src/doom/puredoom/p_lights.c",
        "src/doom/puredoom/p_map.c",    "src/doom/puredoom/p_maputl.c", "src/doom/puredoom/p_mobj.c",
        "src/doom/puredoom/p_plats.c",  "src/doom/puredoom/p_pspr.c",   "src/doom/puredoom/p_saveg.c",
        "src/doom/puredoom/p_setup.c",  "src/doom/puredoom/p_sight.c",  "src/doom/puredoom/p_spec.c",
        "src/doom/puredoom/p_switch.c", "src/doom/puredoom/p_telept.c", "src/doom/puredoom/p_tick.c",
        "src/doom/puredoom/p_user.c",   "src/doom/puredoom/r_bsp.c",    "src/doom/puredoom/r_data.c",
        "src/doom/puredoom/r_draw.c",   "src/doom/puredoom/r_main.c",   "src/doom/puredoom/r_plane.c",
        "src/doom/puredoom/r_segs.c",   "src/doom/puredoom/r_sky.c",    "src/doom/puredoom/r_things.c",
        "src/doom/puredoom/s_sound.c",  "src/doom/puredoom/sounds.c",   "src/doom/puredoom/st_lib.c",
        "src/doom/puredoom/st_stuff.c", "src/doom/puredoom/tables.c",   "src/doom/puredoom/v_video.c",
        "src/doom/puredoom/w_wad.c",    "src/doom/puredoom/wi_stuff.c", "src/doom/puredoom/z_zone.c",
    }, null, &.{
        "doom_print_impl", "doom_gettime_impl",  "doom_malloc_impl", "doom_free_impl",
        "doom_open_impl",  "doom_close_impl",    "doom_read_impl",   "doom_write_impl",
        "doom_seek_impl",  "doom_tell_impl",     "doom_eof_impl",    "doom_exit_impl",
        "keyevent",        "getGfxBufPtr",       "setSampleRate",    "getLeftBufPtr",
        "getRightBufPtr",  "renderSoundQuantum", "init",             "update",
        "renderGfx",
    });

    addExample(b, "tinygl", &.{ "-Wall", "-fno-sanitize=undefined" }, &.{
        "src/tinygl/TinyGL/src/api.c",     "src/tinygl/TinyGL/src/specbuf.c",     "src/tinygl/TinyGL/src/zmath.c",
        "src/tinygl/TinyGL/src/arrays.c",  "src/tinygl/TinyGL/src/image_util.c",  "src/tinygl/TinyGL/src/misc.c",
        "src/tinygl/TinyGL/src/texture.c", "src/tinygl/TinyGL/src/ztriangle.c",   "src/tinygl/TinyGL/src/clear.c",
        "src/tinygl/TinyGL/src/init.c",    "src/tinygl/TinyGL/src/msghandling.c", "src/tinygl/TinyGL/src/vertex.c",
        "src/tinygl/TinyGL/src/clip.c",    "src/tinygl/TinyGL/src/light.c",       "src/tinygl/TinyGL/src/zbuffer.c",
        "src/tinygl/TinyGL/src/error.c",   "src/tinygl/TinyGL/src/list.c",        "src/tinygl/TinyGL/src/zdither.c",
        "src/tinygl/TinyGL/src/get.c",     "src/tinygl/TinyGL/src/matrix.c",      "src/tinygl/TinyGL/src/select.c",
        "src/tinygl/TinyGL/src/zline.c",
    }, &.{
        "src/tinygl/TinyGL/include", "src/tinygl/TinyGL/src",
    }, &.{ "gl_malloc", "gl_zalloc", "gl_free", "zsin", "zcos", "zsqrt", "zpow", "zfabs", "keyevent", "getGfxBufPtr", "setSampleRate", "getLeftBufPtr", "getRightBufPtr", "renderSoundQuantum", "init", "update", "renderGfx" });

    addExample(b, "mandelbrot", null, null, null, &.{
        "mouseMoveEvent",     "mouseClickEvent", "getGfxBufPtr",
        "setSampleRate",      "getLeftBufPtr",   "getRightBufPtr",
        "renderSoundQuantum", "init",            "update",
        "renderGfx",
    });
}
