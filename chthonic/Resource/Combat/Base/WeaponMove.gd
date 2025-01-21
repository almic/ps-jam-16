class_name WeaponMove extends Resource

@export var action: GUIDEAction
## The starting position of the weapon to activate this move
@export var starting: Combat.MovePosition

@export_subgroup("Animation", "anim_")

## The library name, used as a prefix when playing the provided animation.
## Edit the WeaponMove.gd script to add new animation libraries.
@export_enum("SwordAnimations") var anim_library: String

## Animation name as it exists in the animation library
@export var anim_name: String


@export_category("Prerequisites")

## Require this move to be executed after another move
@export_subgroup("After", "after_")

## Only allow this action to follow another
@export var after_enabled: bool

## The specified move this move must follow
@export var after_move: WeaponMove

## The specified move must have this result
@export var after_result: Combat.MoveResult

## Must wait at least this long before executing after the specified move
@export_range(0, 5, 0.1) var after_wait: float

## Must execute within this amount of time after the wait period
@export_range(0, 2, 0.1) var after_time: float
