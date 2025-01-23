@tool
## AI controlled by the player
class_name PuppetAI extends WeaponController

@onready var remote_transform_3d: RemoteTransform3D = %RemoteTransform3D


var master: Player

## Steal the children from the host, give them up for my master!
func _claim(player: Player, host: WeaponController) -> void:
    master = player
    weapon = master.weapon
    weapon_obj = master.weapon_obj
    health = host.health
    i_frames = 60

    var to_visit: Array[Node] = []
    for child in host.get_children():
        child.reparent(self, false)
        to_visit.push_back(child)

    # update owners so unique names are preserved
    # this is a reimplementation of godotengine PR #81506
    while to_visit.size() > 0:
        var child: Node = to_visit.pop_front() as Node
        if not child:
            continue
        child.owner = self
        for c in child.get_children():
            to_visit.push_back(c)


func _ready() -> void:
    # Override to block WeaponController from spawning a weapon
    add_to_group(GROUP.WEAPON_CONTROLLER)
    add_to_group(GROUP.ALIVE)

    # Hold my master!
    remote_transform_3d.reparent(grab_point, false)
    remote_transform_3d.remote_path = master.get_path()

    pass

func enter_combat() -> void:
    super.enter_combat()
    master.enter_combat()

func exit_combat() -> void:
    super.exit_combat()
    master.exit_combat()

func _should_act() -> bool:
    return master._should_act()

func _pick_move() -> WeaponMove:
    return master._pick_move()

func _die() -> void:
    alive = false
    master._on_puppet_died()

func _damage(amount: int) -> bool:
    # We can only die once
    if not alive or health <= 0:
        return false

    health -= amount
    return health <= 0
