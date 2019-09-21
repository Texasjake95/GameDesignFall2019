extends Entity_Base

class_name Player

# This is a demo showing how KinematicBody2D
# move_and_slide works.

# Member variables
const MOTION_SPEED = 160 # Pixels/second


func _physics_process(delta):
	var motion = Vector2()
	
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		motion += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
	
	motion = motion.normalized() * MOTION_SPEED

	collision_manager.moveAndSlide(self, motion)

	if game_conditions.hasWon():
		print("I HAVE WON")
		game_conditions.reset()

	#var collision_info = move_and_collide(motion * delta)
	#if collision_info:
		#if collision_info.collider is Item:
			#collision_info.collider.remove()

