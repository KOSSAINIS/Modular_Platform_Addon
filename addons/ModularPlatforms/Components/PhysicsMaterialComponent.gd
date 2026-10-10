extends Node
class_name PhysicsMaterialComponent

func apply_material(body: CharacterBody2D, velocity: Vector2, delta: float, direction: float = 1.0, max_speed: float = 100.0) -> Vector2:
	var collision: KinematicCollision2D = body.get_last_slide_collision()
	if not collision:
		return velocity
		
	var collider: Object = collision.get_collider()
	
	if collider and "physics_material_override" in collider:
		var material = collider.physics_material_override as PhysicsMaterialOverride
		
		if material:
			var friction: float = material.friction
			var max_friction: float = material.max_friction
			var accelerated_friction: bool = material.accelerated_friction
			var current_max_speed: float = max_speed
			if accelerated_friction:
				# We use clampf to guarantee the speed never drops below 10% of max_speed (0.1) 
				# and never goes above 100% (1.0). 
				# Multiplying friction by 0.5 means a friction of 1.0 reduces speed by 50%.
				var speed_multiplier: float = clampf(1.0 - (friction * 0.5), 0.1, 1.0)
				current_max_speed *= speed_multiplier
			var target_velocity: float = current_max_speed * direction
			
			var step: float
			if direction != 0:
				# Acceleration step.
				step = current_max_speed * 5.0 * delta 
			else:
				# Deceleration step (pure friction when stopping).
				step = (friction * max_friction) * delta 
			
			velocity.x = move_toward(velocity.x, target_velocity, step)
	print(velocity)
	return velocity
