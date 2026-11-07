package window

import "core:c"
import "core:strings"
import rl "vendor:raylib"
import sh "../../engine/string_helper"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 360

Screen :: struct {
    render_target: rl.RenderTexture2D,
    lightmap: rl.RenderTexture2D,
    base_rect: rl.Rectangle,
    scaled_rect: rl.Rectangle,
    origin_vec: rl.Vector2,
    rotation: f32,
    window_mouse_pos: rl.Vector2,
    pixel_mouse_pos: rl.Vector2
}

init_pixel_screen :: proc(ctx: ^Screen, width, height: c.int) -> bool {
    ctx.render_target = rl.LoadRenderTexture(width, height)
    rl.SetTextureFilter(ctx.render_target.texture, .POINT)
    rl.TraceLog(.DEBUG, "Init screen context")

    return rl.IsTextureValid(ctx.render_target.texture)
}

deinit_pixel_screen :: proc(ctx: ^Screen) {
    rl.UnloadRenderTexture(ctx.render_target)
    rl.TraceLog(.DEBUG, "Deinit screen context")
}

set_window_icon :: proc(icon_path: cstring) {
    icon: rl.Image = rl.LoadImage(icon_path)
    if rl.IsImageValid(icon) {
        defer rl.UnloadImage(icon)
        rl.SetWindowIcon(icon)
    }
}

update_pixel_screen_base_rect :: proc(ctx: ^Screen) {
    ctx.base_rect.x = 0
    ctx.base_rect.y = 0
    ctx.base_rect.width = f32(ctx.render_target.texture.width)
    // Flip height for OpenGL present coordinates.
    ctx.base_rect.height = -f32(ctx.render_target.texture.height)
    ctx.origin_vec = rl.Vector2{0, 0}
}

update_pixel_screen_scaled_rect :: proc(ctx: ^Screen) {
    window_width: f32 = f32(rl.GetScreenWidth())
    window_height: f32 = f32(rl.GetScreenHeight())
    scale: f32 = min(f32(window_width)/SCREEN_WIDTH, f32(window_height)/SCREEN_HEIGHT)

    // Center the screen in the window (letterbox).
    ctx.scaled_rect.x = (window_width - (SCREEN_WIDTH * scale)) * 0.5
    ctx.scaled_rect.y = (window_height - (SCREEN_HEIGHT * scale)) * 0.5
    ctx.scaled_rect.width = SCREEN_WIDTH * scale
    ctx.scaled_rect.height = SCREEN_HEIGHT * scale
    ctx.origin_vec = rl.Vector2{0, 0}

    // Update pixel mouse position.
    mouse : rl.Vector2 = rl.GetMousePosition()
    virtual_mouse : rl.Vector2
    virtual_mouse.x = (mouse.x - (window_width - (SCREEN_WIDTH * scale)) * 0.5) / scale
    virtual_mouse.y = (mouse.y - (window_height - (SCREEN_HEIGHT * scale)) * 0.5) / scale
    virtual_mouse = rl.Vector2Clamp(virtual_mouse, rl.Vector2{0, 0}, rl.Vector2{ f32(SCREEN_WIDTH), f32(SCREEN_HEIGHT)})
    ctx.window_mouse_pos = mouse
    ctx.pixel_mouse_pos = virtual_mouse
}

draw_pixel_screen :: proc(ctx: ^Screen) {
    update_pixel_screen_base_rect(ctx)
    update_pixel_screen_scaled_rect(ctx)
    rl.DrawTexturePro(ctx.render_target.texture,
                      ctx.base_rect,
                      ctx.scaled_rect,
                      ctx.origin_vec,
                      ctx.rotation,
                      rl.WHITE)
}
