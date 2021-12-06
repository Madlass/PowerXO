require daslib/media

require utils
require consts

let private WHITE = 0xFFFFFF
let private RED   = 0xFF0000

let private player_collors         = [[uint[4] 0xFF0300BB; 0xFFB10000; 0xFF00C010; 0xFFEBE700]]
let private score_collors          = [[uint[4] 0xFF0400FF; 0xFFFF0000; 0xFF00FF15; 0xFFFFFB00]]

let private BOARD_WIDTH  = 1000
let private BOARD_HEIGHT = 1000

let private  CHOOSE_PLAYER_T = 250
let private  CHOOSE_PLAYER_B = 500

let DELTA = 200

var private
    board_left_top: int2
    board_right_bottom: int2
    board_cell: int2


def private get_cell_center(cell, isActive)
    let left   = isActive ? board_left_top.x : (board_left_top.x + DELTA)
    let top    = isActive ? board_left_top.y : (board_left_top.y + 2*DELTA)
    let right  = isActive ? board_right_bottom.x : (board_right_bottom.x - DELTA)
    let bottom = board_right_bottom.y
    let cell_x = (right - left)/BOARD_CELLS_W_COUNT
    let cell_y = (bottom - top)/BOARD_CELLS_H_COUNT

    return int2(left + cell_x * cell.x + cell_x/2, top + cell_y * cell.y + cell_y/2)


def private get_ball_size(cell, isActive)
    let k = isActive ? 1.0 : (float(BOARD_WIDTH) - float(2*DELTA))/float(BOARD_WIDTH)
    return int(float(min(board_cell.x, board_cell.y))*0.45*k)


def private draw_board(active_player: int; isActive: bool)
    let left   = isActive ? board_left_top.x : (board_left_top.x + DELTA)
    let top    = isActive ? board_left_top.y : (board_left_top.y + 2*DELTA)
    let right  = isActive ? board_right_bottom.x : (board_right_bottom.x - DELTA)
    let bottom = board_right_bottom.y
    let cell_x = (right - left)/BOARD_CELLS_W_COUNT
    let cell_y = (bottom - top)/BOARD_CELLS_H_COUNT

    for i in range(BOARD_CELLS_W_COUNT + 1)
        let x = left + cell_x*i
        line(x, top, x, bottom, 0xffffff )

    for i in range(BOARD_CELLS_H_COUNT + 1)
        let y = top + cell_y*i
        line(left, y, right, y, 0xffffff )


def private draw_balls(balls; isActive: bool)
    for cell, v in keys(balls),values(balls)
        let pos = get_cell_center(cell, isActive)
        fill_circle(pos.x, pos.y, get_ball_size(cell, isActive), player_collors[v])
        circle(pos.x, pos.y, get_ball_size(cell, isActive), WHITE)
        circle(pos.x, pos.y, get_ball_size(cell, isActive)-4, WHITE)


def private draw_selection(selected, active_player; isActive: bool)
    for cell in selected
        let pos = get_cell_center(cell, isActive)
        circle(pos.x, pos.y, get_ball_size(cell, isActive), WHITE)
        circle(pos.x, pos.y, get_ball_size(cell, isActive)-4, score_collors[active_player])


def private draw_scores(scores, active_player)
    let y = 20
    let x = 70
    var i = 0
    let font = 50
    let active_circle_r = font/3
    for s in scores
        set_font_name("mono")
        set_font_size(font)
        text_out(x + 400*i, y, "Score {s}" , score_collors[i])
        if i == active_player
            fill_circle(x + 400*i - active_circle_r - 10, y+font*3/5, active_circle_r, WHITE)
        ++i


def private draw_start_text(selected_player: int)
    set_font_name("mono")
    set_font_size(70)
    text_out(300, 150, "Choose number of players", WHITE)
    let font = 200
    set_font_size(font)
    text_out(240, 250, "2", selected_player == 2 ? RED : WHITE)
    text_out(get_screen_width()/2 - 60, 250, "3", selected_player == 3 ? RED : WHITE)
    text_out(get_screen_width() - 200 - font*2/3, 250, "4", selected_player == 4 ? RED : WHITE)


def public pln_init_board
    board_left_top = int2((get_screen_width() - BOARD_WIDTH)/2, (get_screen_height() - BOARD_HEIGHT)/2)
    board_right_bottom = int2((get_screen_width() + BOARD_WIDTH)/2, (get_screen_height() + BOARD_HEIGHT)/2)
    board_cell = int2(BOARD_WIDTH/BOARD_CELLS_W_COUNT, BOARD_HEIGHT/BOARD_CELLS_H_COUNT)

def public pln_calc_cell_under_mouse(mouse_pos: float2)
    let x = int(mouse_pos.x)
    let y = int(mouse_pos.y)
    if (x < board_left_top.x || y < board_left_top.y || x >= board_right_bottom.x || y >= board_right_bottom.y)
        return INVALID_CELL

    return int2((x - board_left_top.x)/board_cell.x, (y - board_left_top.y)/board_cell.y)


def public pln_calc_player_under_mouse(mouse_pos: float2)
    var x = int(mouse_pos.x)
    var y = int(mouse_pos.y)

    if x < 0 || x > get_screen_width() || y < CHOOSE_PLAYER_T || y > CHOOSE_PLAYER_B
        return 0

    let w = get_screen_width()/3
    return (x/w + 2)


def public pln_drawGame(balls : table<int2; int>; selected: array<int2>; active_player: int; isActive: bool)
    draw_board(active_player, isActive)
    draw_selection(selected, active_player, isActive)
    draw_balls(balls, isActive)


def public pln_drawText(scores: array<int>; active_player: int; selected_number_of_players: int; isActive: bool)
    draw_scores(scores, active_player)
    if (!isActive)
        draw_start_text(selected_number_of_players)
