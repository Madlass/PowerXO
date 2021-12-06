require daslib/media

require utils
require consts

let private WHITE = 0xFFFFFF
let private RED   = 0xFF0000

let private BOARD_COLLOR = WHITE

let private balls_collors_select  = [[uint[4] 0x100B097A; 0x10811010; 0x1013811C; 0x10797710]]
let private balls_collors_balls_1 = [[uint[4] 0xAF02007A; 0xAF790000; 0xAF007009; 0xAF7C7A00]]
let private balls_collors_balls_2 = [[uint[4] 0x10010031; 0x103A0000; 0x10003605; 0x10313000]]
let private score_collors         = [[uint[4] 0xFF0400FF; 0xFFFF0000; 0xFF00FF15; 0xFFFFFB00]]

let private BOARD_TOP_WIDTH  = 800
let private BOARD_BOTTOM_WIDTH  = 1600

let private BOARD_HEIGHT = 600
let private BOARD_OFFSET = 50

let private  CHOOSE_PLAYER_T = 250
let private  CHOOSE_PLAYER_B = 500

struct private BoardH
    top: int
    bot: int

struct private BoardW
    h: int
    w: int

var private
    top_l: int
    top_r: int
    bottom_l: int
    bottom_r: int
    top_h: int
    bottom_h: int
    cell_top_w: int
    cell_bottom_w: int
    cell_bottom_h: int
    cell_top_h: int

    ball_r: int

    board_w: array<BoardW>
    board_h: array<BoardH>
    board_c: table<int2; int2>
    board_s: table<int2; int>


def private draw_board(active_player)
    let col = score_collors[active_player]
    let d = 2
    let dc = 4
    for p in board_h
        line(p.top+dc, top_h, p.bot+dc, bottom_h, col )
        line(p.top-dc, top_h, p.bot-dc, bottom_h, col )
        line(p.top, top_h, p.bot, bottom_h, WHITE )

    for p in board_w
        let x1 = top_l - (p.w - BOARD_TOP_WIDTH)/2
        let x2 = top_r + (p.w - BOARD_TOP_WIDTH)/2
        let y  = top_h + p.h

        line(x1, y + dc, x2, y + dc, col )
        line(x1, y - dc, x2, y - dc, col )
        line(x1, y - d, x2, y, WHITE )


def private draw_ball(cell: int2; player: int; select: bool)
    let r = mix(ball_r*BOARD_TOP_WIDTH/BOARD_BOTTOM_WIDTH, ball_r, board_s[cell])
    let pos = board_c[cell]
    let x = pos.x
    let y = pos.y - r*5/6
    if(select)
        fill_circle(x, y, r, balls_collors_select[player])
    else
        fill_circle(x, y, r, balls_collors_balls_1[player])
        var rd = r*4/5
        var d  = mix(-(r-rd)/2, (r-rd)/2, 100*cell.x/BOARD_CELLS_W_COUNT)
        fill_circle(x-d, y-(r-rd)/2, rd, balls_collors_balls_1[player])
        rd = r*4/7
        d  = mix(-(r-rd)/2, (r-rd)/2, 100*cell.x/BOARD_CELLS_W_COUNT)
        fill_circle(x-d, y-(r-rd)/2, rd, balls_collors_balls_2[player])
        rd = r/7
        d  = mix(-(r-rd)/2, (r-rd)/2, 100*cell.x/BOARD_CELLS_W_COUNT)
        fill_circle(x-d, y-(r-rd)/2, rd, WHITE)

    circle(x, y, r, WHITE)
    circle(x, y, r-2, WHITE)


def private draw_balls(balls)
    for i in range(BOARD_CELLS_W_COUNT)
        for j in range(BOARD_CELLS_H_COUNT)
            let cell = int2(i, j)
            let pV = find(balls, cell)
            if pV != null
                draw_ball(cell, *pV, false)


def private draw_selection(selected, active_player)
    for cell in selected
        draw_ball(cell, active_player, true)


def private draw_start_text(selected_player: int)
    set_font_name("mono")
    set_font_size(70)
    text_out(300, 150, "Choose number of players", WHITE)
    let font = 200
    set_font_size(font)
    text_out(240, 250, "2", selected_player == 2 ? RED : WHITE)
    text_out(get_screen_width()/2 - 60, 250, "3", selected_player == 3 ? RED : WHITE)
    text_out(get_screen_width() - 200 - font*2/3, 250, "4", selected_player == 4 ? RED : WHITE)


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


def public iso_init_board
    top_l     = (get_screen_width() - BOARD_TOP_WIDTH)/2
    top_r     = (get_screen_width() + BOARD_TOP_WIDTH)/2
    bottom_l  = (get_screen_width() - BOARD_BOTTOM_WIDTH)/2
    bottom_r  = (get_screen_width() + BOARD_BOTTOM_WIDTH)/2
    top_h     = get_screen_height() - BOARD_HEIGHT - BOARD_OFFSET
    bottom_h  = get_screen_height() - BOARD_OFFSET

    cell_bottom_w = BOARD_BOTTOM_WIDTH/BOARD_CELLS_W_COUNT
    cell_top_w    = BOARD_TOP_WIDTH/BOARD_CELLS_W_COUNT
    cell_bottom_h = BOARD_HEIGHT/BOARD_CELLS_H_COUNT
    cell_top_h    = cell_bottom_h*BOARD_TOP_WIDTH/BOARD_BOTTOM_WIDTH

    ball_r = cell_bottom_w*3/7

    for i in range(BOARD_CELLS_W_COUNT + 1)
        let top = top_l + cell_top_w * i
        let bot = bottom_l + cell_bottom_w * i
        push(board_h, [[BoardH top=top, bot=bot]])

    for i in range(BOARD_CELLS_H_COUNT + 1)
        let h = mix(cell_top_h, cell_bottom_h, 100*i/BOARD_CELLS_H_COUNT)*i
        let w = mix(BOARD_TOP_WIDTH, BOARD_BOTTOM_WIDTH, 100*h/BOARD_HEIGHT)
        push(board_w, [[BoardW h=h, w=w]])

    for i in range(BOARD_CELLS_H_COUNT)
        let h1 = mix(cell_top_h, cell_bottom_h, 100*i/BOARD_CELLS_H_COUNT)*i
        let h2 = mix(cell_top_h, cell_bottom_h, 100*(i+1)/BOARD_CELLS_H_COUNT)*(i+1)
        let h = (h1 + h2)/2
        let k = 100*h/BOARD_HEIGHT
        let w = mix(BOARD_TOP_WIDTH, BOARD_BOTTOM_WIDTH, k)
        let cell_w =  w/BOARD_CELLS_W_COUNT
        let start = (get_screen_width() - w)/2

        for j in range(BOARD_CELLS_W_COUNT)
            board_s[int2(j, i)] = k
            board_c[int2(j, i)] = int2((start + j*w/BOARD_CELLS_W_COUNT + cell_w/2), top_h + h)


def public iso_calc_cell_under_mouse(mouse_pos: float2)
    var x = int(mouse_pos.x)
    var y = int(mouse_pos.y)

    let w = mix(BOARD_TOP_WIDTH, BOARD_BOTTOM_WIDTH, 100*(y-top_h)/BOARD_HEIGHT)
    let cell_w = w/BOARD_CELLS_W_COUNT
    x = x - (get_screen_width() - w)/2
    var cell = INVALID_CELL

    if (y > bottom_h || y < top_h || x < 0 || x > w)
        return INVALID_CELL

    var i = 0
    for p in board_w
        if y < top_h + p.h
            return int2(x/cell_w, i-1)
        ++i

    return INVALID_CELL


def public iso_calc_player_under_mouse(mouse_pos: float2)
    var x = int(mouse_pos.x)
    var y = int(mouse_pos.y)

    if x < 0 || x > get_screen_width() || y < CHOOSE_PLAYER_T || y > CHOOSE_PLAYER_B
        return 0

    let w = get_screen_width()/3
    return (x/w + 2)


def public iso_drawGame(balls : table<int2; int>; selected: array<int2>; active_player: int; isActive: bool)
    draw_board(active_player)
    draw_selection(selected, active_player)
    draw_balls(balls)


def public iso_drawText(scores: array<int>; active_player: int; selected_number_of_players: int; isActive: bool)
    draw_scores(scores, active_player)
    if (!isActive)
        draw_start_text(selected_number_of_players)
