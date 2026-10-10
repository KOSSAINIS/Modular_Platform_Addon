extends PhysicsMaterial
class_name PhysicsMaterialOverride

# Good use of export. I recommend giving it a default value that matches standard friction behavior.
@export var max_friction: float = 1000.0
@export var accelerated_friction: bool = true
