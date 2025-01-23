class_name CombatWeapon extends Resource

## Weapon Type
@export var weapon_type: WeaponType

## Weapon's Move Set
@export var move_set: WeaponMoveSet

## Weapon's Input Mapping Context
@export var mapping_context: GUIDEMappingContext

## Weapon's Scene
@export var weapon_scene: PackedScene

## Weapon's damage multiplier
@export_range(0.01, 2) var damage_multiplier: float = 1

## Animation library name which holds the Move Set's animations
## Edit the CombatWeapon.gd script to add new animation libraries.
@export_enum("SwordAnimations") var animation_library: String

@export_subgroup("Animations", "anim_")
## Name of the idle animation as it exists in the Animation Library
@export var anim_idle_name: String
