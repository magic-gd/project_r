extends KinematicBody2D

# Enemy

export(bool) var invincible = false
export var throw_strength = 5
export var push_strength = 50
export(int) var health = 3


func _on_CollisionArea_area_entered(body):
	if body.is_in_group("player"):
		body.take_damage($ThrowPoint.global_position, throw_strength)


func _physics_process(delta):
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("player"):
			collision.collider.knockback($ThrowPoint.global_position, throw_strength)


func take_damage(source: Vector2, strength: int):
	if invincible:
		return
	
#	print(str(self) + "took damage")
	$DamageAnimationPlayer.play("dmg_flash")
	health -= strength
	if health <= 0:
		die()


func die():
	queue_free()

