#import "Basic";
#import "Window_Creation";
#import "Input";
#import "Math";
Simp :: #import "Simp";

window_width  :: 800;
window_height :: 600;
quad_size     :: 100.0;

shape_color      :: Vector4.{x=.2, y=.8, z=.2, w=1};
background_color :: Vector4.{x=.1, y=.1, z=.1, w=1};
grid_color0      :: background_color;
grid_color1      :: Vector4.{x=.2, y=.2, z=.2, w=1};
grid_percent     :: 0.5;
// NOTE: we are trying to keep the grid square (for some reason, I don't know why, I just feel like it)
#if window_height < window_width {
    grid_width    :: window_height;
    grid_height   :: window_height;
    grid_x        : float : window_width*grid_percent - grid_width*grid_percent;
    grid_y        : float : 0.0;
} else {
    grid_width    :: window_width;
    grid_height   :: window_width;
    grid_x        : float : 0.0;
    grid_y        : float : window_height*grid_percent - grid_height*grid_percent;
}
grid_cols        :: 10;
grid_rows        :: 10;
grid_cell_width  :: grid_width / grid_cols;
grid_cell_height :: grid_height / grid_rows;
step_interval    :: 0.5;
DT_MAX : float : 0.15;

immediate_cell_quad :: (col: s64, row: s64, color: Vector4) {
    if col < 0 || col >= grid_cols return;
    if row < 0 || row >= grid_rows return;

    x : float = grid_x + xx (col*grid_cell_width);
    y : float = grid_y + xx (row*grid_cell_height);
    w : float = grid_cell_width;
    h : float = grid_cell_height;
    Simp.immediate_quad(x, y, x + w, y + h, color);
}

immediate_shape :: (ocol: s64, orow: s64) {
    immediate_cell_quad(ocol + 0, orow + 0, shape_color);
    immediate_cell_quad(ocol + 1, orow + 0, shape_color);
    immediate_cell_quad(ocol + 2, orow + 0, shape_color);
    immediate_cell_quad(ocol + 2, orow + 1, shape_color);
}

main :: () {
    last_time := get_time();

    window := create_window(window_name="Tetris", width=window_width, height=window_height);

    should_quit_game := false;

    Simp.set_render_target(window);

    col := 0;
    row := grid_rows;
    step_timeout := step_interval;

    while !should_quit_game {
        now := get_time();
        delta : float64 = now - last_time;
        current_dt := cast(float) delta;

        if current_dt > DT_MAX current_dt = DT_MAX;

        last_time = now;

        {
            using background_color;
            Simp.clear_render_target(x, y, z, w);
        }
        update_window_events();

        for event : events_this_frame {
            if event.type == {
                case .QUIT; {
                    should_quit_game = true;
                    break;
                }

                case .KEYBOARD; if event.key_pressed {
                    if event.key_code == {
                        case .ESCAPE;      should_quit_game = true; break;
                        case .ARROW_LEFT;  col -= 1;
                        case .ARROW_RIGHT; col += 1;
                    }
                }
            }
        }

        step_timeout -= current_dt;
        if step_timeout < 0 {
            step_timeout = step_interval;
            row -= 1;
        }

        Simp.set_shader_for_color();
        for col: 0..grid_cols-1 {
            for row: 0..grid_rows-1 {
                color := ifx (col + row)%2 == 0 then grid_color0 else grid_color1;
                immediate_cell_quad(col, row, color);
            }
        }

        immediate_shape(col, row);

        Simp.swap_buffers(window);
    }
}
