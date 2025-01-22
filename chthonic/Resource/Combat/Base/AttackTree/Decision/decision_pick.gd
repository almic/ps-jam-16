## Picks from a set of decisions with a probability
class_name DecisionPick extends AttackDecision

@export var first: AttackDecision
@export_range(0, 1, 0.05) var first_chance: float = 0.5

@export var second: AttackDecision
@export_range(0, 1, 0.05) var second_chance: float = 1

@export_subgroup("More")
@export var third: AttackDecision
@export_range(0, 1, 0.05) var third_chance: float = 0.2

@export var fourth: AttackDecision
@export_range(0, 1, 0.05) var fourth_chance: float = 0.2

## If none of the others pass, this is picked. Setting this is NOT required,
## as long as at least one of the previous options has a 100% of being picked.
@export var final: AttackDecision
