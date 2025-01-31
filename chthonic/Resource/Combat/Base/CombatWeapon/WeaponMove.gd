class_name WeaponMove extends Resource

@export var name: String
@export var action: GUIDEAction

## Damage to inflict when this move hits
@export_range(0, 100) var damage: int

## The starting position of the weapon to activate this move
@export var starting: Combat.MovePosition

@export_subgroup("Animation", "anim_")
## Animation name as it exists in the animation library
@export var anim_name: String

@export_category("Prerequisites")

## Require this move to be executed after another move
@export_subgroup("After", "after_")

## Only allow this action to follow another
@export var after_enabled: bool

## The specified move this move must follow. Must have `after_enabled` set to
## `true` for this to take effect.
@export var after_move: WeaponMove

## The specified move must have this result. Valid values are `Unset` and `Hit`.
## Must have `after_enabled` set to`true` for this to take effect.
@export var after_result: Combat.MoveResult
