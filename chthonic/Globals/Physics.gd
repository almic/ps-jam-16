class_name PHYSICS

## Get intersection points and normal (up) between two CollisionObject3D as a
## dictionary. `point` is the intersection coordinate, and `normal` is the direction
static func intersection_location(a: CollisionObject3D, b: CollisionObject3D) -> Dictionary:
    var collision_shape: CollisionShape3D = a.shape_owner_get_owner(0) as CollisionShape3D

    var params := PhysicsShapeQueryParameters3D.new()
    params.collide_with_areas = b is Area3D
    params.shape = collision_shape.shape
    params.transform = collision_shape.global_transform
    params.exclude = [a.get_rid()]
    params.collision_mask = b.collision_layer

    var space := a.get_world_3d().direct_space_state
    return space.get_rest_info(params)

static func intersection_points(a: CollisionObject3D, b: CollisionObject3D, maximum: int = 3) -> Array[Vector3]:
    var collision_shape: CollisionShape3D = a.shape_owner_get_owner(0) as CollisionShape3D

    var params := PhysicsShapeQueryParameters3D.new()
    params.collide_with_areas = b is Area3D
    params.shape = collision_shape.shape
    params.transform = collision_shape.global_transform
    params.exclude = [a.get_rid()]
    params.collision_mask = b.collision_layer

    var space := a.get_world_3d().direct_space_state
    var points := space.collide_shape(params, maximum)

    var results: Array[Vector3]
    var index = 0
    while index < points.size():
        results.append(points[index].lerp(points[index + 1], 0.5))
        index += 2

    return results
