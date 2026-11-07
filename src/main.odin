package main

import "core:fmt"
import "core:mem"
import imgui "../external/odin-raylib-imgui-template/lib/odin-imgui"
import rlimgui "../external/odin-raylib-imgui-template/lib/imgui_impl_raylib"
import rl "vendor:raylib"
import sh "engine/string_helper"
import window "engine/window"

main :: proc() {
    when ODIN_DEBUG {
        // Yanked from Odin "Tracking Allocator" example:
        // https://odin-lang.org/docs/overview/#tracking-allocator

        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }
            else {
                fmt.println("ODIN: No memory leaks!")
            }

            mem.tracking_allocator_destroy(&track)
        }

        rl.SetTraceLogLevel(.DEBUG)
    }

    rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
    rl.InitWindow(window.WINDOW_WIDTH, window.WINDOW_HEIGHT, "Raylodin Template")
    defer rl.CloseWindow()
    rl.TraceLog(rl.TraceLogLevel.DEBUG, sh.join_to_cstring({"Current working directory: ",
                                                            string(rl.GetWorkingDirectory())}))

    imgui.CreateContext()
    defer imgui.DestroyContext()
    imgui.GetIO().IniFilename = nil // Don't generate save config for imgui.
    rlimgui.init()
    defer rlimgui.shutdown()

    screen: window.Screen
    window.init_pixel_screen(&screen, window.SCREEN_WIDTH, window.SCREEN_HEIGHT)
    defer window.deinit_pixel_screen(&screen)
    window.set_window_icon("assets/elgato.png")

    draw_debug : bool = false

    for !rl.WindowShouldClose() {
        if rl.IsKeyPressed(rl.KeyboardKey.F1) {
            draw_debug = !draw_debug
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)

            rl.BeginTextureMode(screen.render_target)
                rl.ClearBackground(rl.BLUE)
                rl.DrawText("Press F1 to toggle debug window.", 20, 20, 20, rl.WHITE)
            rl.EndTextureMode()

            window.draw_pixel_screen(&screen)

            if draw_debug {
                rlimgui.begin() // Begin/end an imgui window.
                    imgui.Text("mouse pos (w): %f, %f", screen.window_mouse_pos.x,
                                                        screen.window_mouse_pos.y)
                    imgui.Text("mouse pos (s): %f, %f", screen.pixel_mouse_pos.x,
                                                        screen.pixel_mouse_pos.y)
                rlimgui.end()
            }

        rl.EndDrawing()
    }
}
