require daslib/media
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code

require model public

let VT_DELTA = 0.5

var
    img <- create_image("back.png")
    vT: float = 0.5


def drawHelperText()
    set_font_name("mono")
    set_font_size(30)
    text_out(505, 1160, "Change view 'v' | End game - 'e'", 0xffffff)


// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_resolution(1600, 1200)
    set_window_title("PowXO")
    init()
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    vT+=dt

    if get_key(VK_ESCAPE)
        schedule_quit_game()

    if get_key(VK_E)
        end()

    if get_key(VK_V) && (vT > VT_DELTA)
        vT = 0.0
        changeView()

    if (isActive())
        update()

    mouseMove(get_mouse_position())
    if get_mouse_button_up(MB_LEFT)
        mouseClick(get_mouse_position())

    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    img |> draw_image(0, 0)
    drawHelperText()
    drawText()

    enable_premultiplied_alpha_blend()
    drawGame()


    return
