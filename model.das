require daslib/media

require utils
require consts
require model_draw_iso public
require model_draw_pln public


var private
    selected: array<int2>
    start_cell: int2 = INVALID_CELL

    selected_number_of_players: int = 0
    number_of_players : int = 0
    active_player : int = 0
    balls: table<int2; int>
    players_cant_move: array<int>
    scores: array<int>

    planeActive: bool = false


def private add_balls()
    scores[active_player] += length(selected)
    for i in selected
        balls[i] = active_player


def private next_player
    active_player += 1
    if active_player >= number_of_players
        active_player = 0


def private is_first_ball()
    for v in values(balls)
        if v == active_player
            return false
    return true


def private is_empty_cell(cell)
    return find(balls, cell) == null


def private enabled(cell)
    let pV = find(balls, cell)
    return pV != null && *pV == active_player


def private d_enabled(cell)
    for i in [[int -1; 1]]
        for j in [[int -1; 1]]
            if enabled(int2(cell.x + i, cell.y + j))
                return true
    return false


def private hw_enabled(cell)
    for i in [[int -1; 1]]
        if enabled(int2(cell.x + i, cell.y)) || enabled(int2(cell.x, cell.y + i))
            return true
    return false


def private change_player_if_needed
    for p in players_cant_move
        if p == active_player
            next_player()
            return

    for i in range(BOARD_CELLS_W_COUNT)
        for j in range(BOARD_CELLS_H_COUNT)
            if (can_select(int2(i,j)))
                return

    push(players_cant_move, active_player)
    next_player()


def private can_select(cell)
    if (!is_empty_cell(cell))
        return false

    if (start_cell != INVALID_CELL)
        return !hw_enabled(cell)

    if (is_first_ball())
        return true

    return d_enabled(cell) && !hw_enabled(cell)


def private select_array(start_cell, cell, rot)
    let x1 = rot ? start_cell.y : start_cell.x
    let y1 = rot ? start_cell.x : start_cell.y
    let x2 = rot ? cell.y : cell.x
    let y2 = rot ? cell.x : cell.y

    if (x1 != x2)
        return false

    for i in get_selected_range(y1, y2)
        let c = rot ? int2(i, x1) : int2(x1, i)
        if (can_select(c))
            push(selected, c)
        else
            clear(selected)
            return false

    return true


def choose_players_count(mouse_pos: float2)
    selected_number_of_players = calc_player_under_mouse(mouse_pos)


def private update_selected(mouse_pos: float2)
    clear(selected)
    let cell = calc_cell_under_mouse(mouse_pos)

    if start_cell == INVALID_CELL
        if cell != INVALID_CELL && can_select(cell)
            push(selected, cell)
        return

    if cell != INVALID_CELL && cell != start_cell
        if (select_array(start_cell, cell, false) || select_array(start_cell, cell, true))
            return

    push(selected, start_cell)


def private set_number_of_players()
    number_of_players = selected_number_of_players
    for i in range(4)
        push(scores, 0)


def private clear_model()
    clear(selected)
    clear(balls)
    clear(scores)
    clear(players_cant_move)
    start_cell = INVALID_CELL
    active_player = 0
    number_of_players = 0


def private calc_cell_under_mouse(mouse_pos: float2)
    if (planeActive)
        return pln_calc_cell_under_mouse(mouse_pos)
    else
        return iso_calc_cell_under_mouse(mouse_pos)


def private calc_player_under_mouse(mouse_pos: float2)
    if (planeActive)
        return pln_calc_player_under_mouse(mouse_pos)
    else
        return iso_calc_player_under_mouse(mouse_pos)


def private mouse_click_when_active(mouse_pos: float2)
    if (start_cell != INVALID_CELL)
        add_balls()
        next_player()
        start_cell = INVALID_CELL
    else
        let cell = calc_cell_under_mouse(mouse_pos)
        if (can_select(cell))
            start_cell = cell


def private mouse_click_when_passive()
    if (selected_number_of_players == 0)
        return
    clear_model()
    set_number_of_players()


def public isActive
    return length(players_cant_move) < number_of_players


def public update
    change_player_if_needed()


def public init()
    pln_init_board()
    iso_init_board()


def public end()
    number_of_players = 0


def public changeView
    planeActive = !planeActive


def public mouseClick(mouse_pos: float2)
    if (isActive())
        mouse_click_when_active(mouse_pos)
    else
        mouse_click_when_passive()


def public mouseMove(mouse_pos: float2)
    if (isActive())
        update_selected(mouse_pos)
    else
        choose_players_count(mouse_pos)


def public drawText()
    if (planeActive)
        pln_drawText(scores, active_player, selected_number_of_players, isActive())
    else
        iso_drawText(scores, active_player, selected_number_of_players, isActive())


def public drawGame()
    if (planeActive)
        pln_drawGame(balls, selected, active_player, isActive())
    else
        iso_drawGame(balls, selected, active_player, isActive())
