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

static var camera: Camera3D
static func get_camera(node: Node3D) -> Camera3D:
    if not camera:
        camera = node.get_tree().root.get_camera_3d()
    return camera

