extends CharacterBody2D


const SPEED = 5000.0
var direction: Vector2 = Vector2.LEFT
var test = true

func _ready():
	direction = global_position.direction_to(GameManager.player_node.global_position)
	var angle_conv = rad_to_deg(global_position.angle_to_point(GameManager.player_node.global_position))
	rotation_degrees = angle_conv

func _physics_process(delta):
	velocity.x = move_toward(velocity.x, SPEED * direction.x, SPEED)
	velocity.y = move_toward(velocity.y, SPEED * direction.y, SPEED)
	#rotation = angle_conv
	move_and_slide()


func _on_timer_timeout():
	queue_free()
