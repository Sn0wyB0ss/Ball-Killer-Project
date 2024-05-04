extends CharacterBody2D

@onready var player_catch = $PlayerCatch
@onready var parry_timer = $ParryTimer

var camera_node: Camera2D = null

var left_border_limit: int = 0
var right_border_limit: int = 0
var top_border_limit: int = 0
var bottom_border_limit: int = 0
var half_dist_spd = 0
var first_half = false
var initial_speed: float = 1000.0
var max_speed: float = 1500.0
var speed: float = initial_speed

var direction: Vector2 = Vector2(-1,0)

var return_to_player = false

var follow_near_enemy = false
var enemy_to_follow = null

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_node = GameManager.get_camera()
	left_border_limit = camera_node.limit_left
	right_border_limit = camera_node.limit_right
	top_border_limit = camera_node.limit_top
	bottom_border_limit = camera_node.limit_bottom
	
func _process(delta):
	if Input.is_action_just_pressed("kick") and parry_timer.time_left <= 0.0:
		parry_timer.start()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		
	if (return_to_player):
		direction = Vector2.RIGHT.rotated(global_position.angle_to_point(GameManager.player_node.global_position))
		
	if (enemy_to_follow != null) and (follow_near_enemy):
		direction = Vector2.RIGHT.rotated(global_position.angle_to_point(enemy_to_follow.global_position))

	if (global_position.distance_to(GameManager.player_node.global_position) <= 128) and return_to_player:
		if (!first_half):
			half_dist_spd = (global_position.distance_to(GameManager.player_node.global_position)) / 3
			first_half = true
		speed = clamp(speed,initial_speed,max_speed)
	
		velocity.x = move_toward(velocity.x,  direction.x * half_dist_spd, half_dist_spd)
	
		# Vertical Accel and Deccel Check	
		velocity.y = move_toward(velocity.y,  direction.y * half_dist_spd, half_dist_spd)
	else:
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
		enemy_to_follow = null
		
	if (global_position.x > right_border_limit):
		direction.x = -direction.x
		global_position.x = right_border_limit
		return_to_player = true
		enemy_to_follow = null
		
	if (global_position.y < top_border_limit):
		direction.y = -direction.y
		global_position.y = top_border_limit
		return_to_player = true
		enemy_to_follow = null
		
	if (global_position.y > bottom_border_limit):
		direction.y = -direction.y
		global_position.y = bottom_border_limit
		return_to_player = true
		enemy_to_follow = null


func _on_player_catch_body_entered(body):
	if (!return_to_player):
		return
	if (parry_timer.time_left > 0.0):
		parry()
		parry_timer.stop()
		return
	queue_free()
	GameManager.player_node.ball_gathered = true
	GameManager.player_node.start_kick_delay()
	speed = initial_speed

func oppsite_direction(direction_vector):
	var oppsite_x_dir_sign: int = sign(direction_vector.x)
	var oppsite_y_dir_sign: int = sign(direction_vector.y)
	if oppsite_x_dir_sign == 0:
		oppsite_x_dir_sign = 1
	if oppsite_y_dir_sign == 0:
		oppsite_y_dir_sign = 1
	direction = direction * Vector2(sign(direction.x) * oppsite_x_dir_sign, sign(direction.y) * oppsite_y_dir_sign)
	

func _on_parry_hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	pass
	
func parry():
	return_to_player = false
	oppsite_direction(Vector2.RIGHT.rotated(GameManager.player_node.global_position.angle_to_point(global_position)))
	parry_initial_check()
	speed *= 1.11

func _on_ball_hitbox_body_entered(body):
	pass


func _on_ball_hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	return_to_player = true
	enemy_to_follow = null
	oppsite_direction(Vector2.RIGHT.rotated(area.global_position.angle_to_point(global_position)))
	speed *= 1.11

func near_enemy():
	var enemies_nodes = get_tree().get_nodes_in_group("enemies")
	if enemies_nodes.is_empty():
		return null
	var most_near_enemy = null
	var min_distance = INF
	for enemy in enemies_nodes:
		var enemy_distance = enemy.global_position.distance_to(global_position)
		if enemy_distance < min_distance:
			most_near_enemy = enemy
			min_distance = enemy_distance
	return most_near_enemy

func near_enemy_to_angle():
	var enemies_nodes = get_tree().get_nodes_in_group("enemies")
	if enemies_nodes.is_empty():
		return null
	var most_near_enemy = null
	var min_distance = INF
	for enemy in enemies_nodes:
		var enemy_distance = enemy.global_position.distance_to(global_position)
		var dir_to_enemy = -rad_to_deg(global_position.angle_to_point(enemy.global_position))
		var left_dir = -rad_to_deg(direction.angle()) + 45
		var right_dir = -rad_to_deg(direction.angle()) - 45
		var left_dir_check = left_dir >= dir_to_enemy
		var right_dir_check = right_dir <= dir_to_enemy
		var between_angles = left_dir_check and right_dir_check
		print()
		if enemy_distance < min_distance and between_angles:
			most_near_enemy = enemy
			min_distance = enemy_distance
	return most_near_enemy

func parry_initial_check():
	enemy_to_follow = near_enemy()
	
	if enemy_to_follow == null:
		follow_near_enemy = false
		return
		
	if enemy_to_follow:
		follow_near_enemy = true
		return

func throw_initial_check():
	enemy_to_follow = near_enemy_to_angle()
	
	if enemy_to_follow == null:
		follow_near_enemy = false
		return
		
	if enemy_to_follow:
		follow_near_enemy = true
		return
