## Defines combat constants and maybe some helper functions
class_name Combat

enum MovePosition {
    Unset,
    Center,
    Left,
    Right,
    Down,
    Up,
    UpLeft,
    UpRight,
    DownLeft,
    DownRight
}

enum MoveResult {
    Unset,
    Miss,
    Hit
}

enum Stance {
    Unset,
    Idle,
    PreAction,
    Action,
    PostAction,
    Deflected,
    Staggered
}
