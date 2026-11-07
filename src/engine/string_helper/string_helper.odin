package string_helper

import "core:strings"
import rl "vendor:raylib"

join :: proc(items: []string) -> string
{
    // Join with no specific separator.
    return strings.join(items, "", context.temp_allocator)
}

join_to_cstring :: proc(items: []string) -> cstring
{
    return strings.clone_to_cstring(join(items), context.temp_allocator)
}
