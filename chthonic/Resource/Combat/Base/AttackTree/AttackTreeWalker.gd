class_name AttackTreeWalker

var tree: AttackTree
var node: AttackTreeNode
var decision: AttackDecision

var _node_index: int = -1
var _pattern_index: int = -1

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(attack_tree: AttackTree):
    tree = attack_tree

## Begin by picking the next node on the tree
func begin():
    _node_index += 1
    if _node_index >= tree.nodes.size():
        _node_index = 0

    node = tree.nodes[_node_index]
    _pattern_index = -1

## Returns `true` if the active node's pattern matches the given move set
func match_move_set(move_set: WeaponMoveSet) -> bool:
    return node.pattern.move_set == move_set

## Pick the next attack decision. Returns `null` when empty
func next() -> AttackDecision:
    if not node:
        decision = null
    elif _pattern_index >= node.pattern.pattern.size() - 1:
        decision = null
    else:
        _pattern_index += 1
        decision = node.pattern.pattern[_pattern_index]

    return decision

## Handles a DecisionPick, returning the first successful
## non-pick decision
func handle_pick(maybe_pick: AttackDecision) -> AttackDecision:
    if not maybe_pick is DecisionPick:
        return maybe_pick

    var pick: DecisionPick = maybe_pick as DecisionPick

    if not pick.second or pick.first_chance >= 1 or _rng.randf() <= pick.first_chance:
        return handle_pick(pick.first)

    if not pick.third or pick.second_chance >= 1 or _rng.randf() <= pick.second_chance:
        return handle_pick(pick.second)

    if not pick.fourth or pick.third_chance >= 1 or _rng.randf() <= pick.third_chance:
        return handle_pick(pick.third)

    if not pick.final or pick.fourth_chance >= 1 or _rng.randf() <= pick.fourth_chance:
        return handle_pick(pick.fourth)

    return handle_pick(pick.final)

## Handles a DecisionRandom, returning `true` if it passed, `false` otherwise
func handle_random(random: DecisionRandom) -> bool:
    return _rng.randf() <= random.probability
