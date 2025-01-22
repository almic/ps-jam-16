@tool
class_name KnightAI extends AIController

func on_arrived() -> void:
    var target = brain.target.get_memory()
    if not target:
        return

    if target is WeaponController:
        enter_combat()

        # Tell player to enter combat
        if target is Player:
            if DEBUG_PRINT:
                print("%s fight me, human!" % name)
            var player: Player = target as Player
            player.enter_combat()
        else:
            print("%s fight me, %s!" % [name, target.name])


