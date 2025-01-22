## Checks the opponent's current state, passing if all set fields match
class_name DecisionCheck extends AttackDecision

## If this matches when opponent is performing no move (is idle)
@export var no_move: bool = false

## Move to match, null to match any move
@export var move: WeaponMove = null

## Stance to match, Unset to match any stance
@export var stance: Combat.Stance = Combat.Stance.Unset
