extends Node
class_name PhysicsMaterialComponent

var _previous_velocity: Vector2 = Vector2.ZERO

func apply_material(body: CharacterBody2D, velocity: Vector2, delta: float, direction: float = 1.0, max_speed: float = 100.0) -> Vector2:
	var collision: KinematicCollision2D = body.get_last_slide_collision()
	
	# We calculate the new physics, then save it to _previous_velocity before returning it
	var new_velocity = _calculate_physics(body, velocity, delta, direction, max_speed, collision)
	_previous_velocity = new_velocity
	
	return new_velocity


func _calculate_physics(body: CharacterBody2D, velocity: Vector2, delta: float, direction: float = 1.0, max_speed: float = 100.0, collision:KinematicCollision2D = null) -> Vector2:
	if not collision:
		return velocity
		
	var collider: Object = collision.get_collider()
	
	if collider and "physics_material_override" in collider:
		var material = collider.physics_material_override as PhysicsMaterialOverride
		
		if material:
			# Extract all properties
			var friction: float = material.friction
			var max_friction: float = material.max_friction
			var rough: bool = material.rough
			var bounce: float = material.bounce
			var absorbent: bool = material.absorbent
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
				if rough:
					# ROUGH IS TRUE: The surface's friction overrides your character's perfect grip.
					# If it's ice (friction 0.1), you accelerate terribly. 
					# We clamp to 0.1 so you don't get completely permanently paralyzed on 0 friction ice.
					step = current_max_speed * max(friction, 0.1) * 5.0 * delta
				else:
					# ROUGH IS FALSE: You accelerate normally, ignoring floor friction until you try to stop.
					step = current_max_speed * 5.0 * delta
			else:
				# Deceleration step (pure friction when stopping).
				step = (friction * max_friction) * delta 
			
			velocity.x = move_toward(velocity.x, target_velocity, step)
	
			var normal: Vector2 = collision.get_normal()
			
			# Check if this is a floor (normal pointing up) AND we were falling last frame
			if normal.y < -0.5 and _previous_velocity.y > 10.0:
				if absorbent:
					# ABSORBENT IS TRUE: Mud/Mattress. Kills downward momentum and entirely prevents bouncing.
					velocity.y = 0 
				elif bounce > 0.0:
					var bounce_power: float = -_previous_velocity.y * bounce
						
					# -50.0 means the character must be bouncing upward with at least a speed of 50.
					if bounce_power < -50.0: 
						velocity.y = bounce_power
					else:
						# The bounce was too weak. Force them to stop so they can jump again.
						velocity.y = 0 
	
	
	print(velocity)
	return velocity
