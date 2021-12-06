require daslib/media

def get_selected_range(a, b)
    return range(min(a, b), max(a, b)+1)

def mix(v1: int; v2: int; k: int)
    return v1 + (v2-v1)*k/100