extends CharacterBody2D

@onready var player_catch = $PlayerCatch

var camera_node: Camera2D = null

var left_border_limit: int = 0
var right_border_limit: int = 0
var top_border_limit: int = 0
var bottom_border_limit: int = 0

var initial_speed: float = 1000.0
var max_speed: float = 2500.0
var speed: float = initial_speed

var direction: Vector2 = Vector2(-1,0)

var return_to_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_node = GameManager.get_camera()
	left_border_limit = camera_node.limit_left
	right_border_limit = camera_node.limit_right
	top_border_limit = camera_node.limit_top
	bottom_border_limit = camera_node.limit_bottom
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	if (return_to_player):
		direction = Vector2.RIGHT.rotated(global_position.angle_to_point(GameManager.player_node.global_position))

	speed = clamp(speed,initial_speed,max_speed)
	
	velocity.x = move_toward(velocity.x,  direction.x * speed, speed)
	
	# Vertical Accel and Deccel Check	
	velocity.y = move_toward(velocity.y,  direction.y * speed, speed)
	
	move_and_collide(velocity * delta)
	
	collide_with_border()
	
func collide_with_border():
	
	if (global_position.x < left_border_limit):
		direction.x = -direction.x
		global_position.x = left_border_limit
		return_to_player = true
		
	if (global_position.x > right_border_limit):
		direction.x = -direction.x
		global_position.x = right_border_limit
		return_to_player = true
		
	if (global_position.y < top_border_limit):
		direction.y = -direction.y
		global_position.y = top_border_limit
		return_to_player = true
		
	if (global_position.y > bottom_border_limit):
		direction.y = -direction.y
		global_position.y = bottom_border_limit
		return_to_player = true


func _on_player_catch_body_entered(body):
	if (!return_to_player):
		return
	queue_free()
	GameManager.player_node.ball_gathered = true
	GameManager.player_node.start_kick_delay()
	speed = initial_speed

func _on_parry_hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	return_to_player = false
	var player_x_dir_sign: int = sign(GameManager.player_node.fixed_direction.x)
	var player_y_dir_sign: int = sign(GameManager.player_node.fixed_direction.y)
	if player_x_dir_sign == 0:
		player_x_dir_sign = 1
	if player_y_dir_sign == 0:
		player_y_dir_sign = 1
	direction = direction* Vector2(sign(direction.x) * player_x_dir_sign, sign(direction.y) * player_y_dir_sign)
	speed *= 1.11
