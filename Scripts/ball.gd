extends CharacterBody2D

@onready var player_catch = $PlayerCatch

var camera_node: Camera2D = null

var left_border_limit: int = 0
var right_border_limit: int = 0
var top_border_limit: int = 0
var bottom_border_limit: int = 0

var speed: float = 1000.0

var direction: Vector2 = Vector2(-1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_node = GameManager.get_camera()
	left_border_limit = camera_node.limit_left
	right_border_limit = camera_node.limit_right
	top_border_limit = camera_node.limit_top
	bottom_border_limit = camera_node.limit_bottom
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	velocity.x = move_toward(velocity.x,  direction.x * speed, speed)
	
	# Vertical Accel and Deccel Check	
	velocity.y = move_toward(velocity.y,  direction.y * speed, speed)
	
	move_and_collide(velocity * delta)
	
	collide_with_border()
	
func collide_with_border():
	
	if (global_position.x < left_border_limit):
		direction.x = -direction.x
		global_position.x = left_border_limit
		
	if (global_position.x > right_border_limit):
		direction.x = -direction.x
		global_position.x = right_border_limit
		
	if (global_position.y < top_border_limit):
		direction.y = -direction.y
		global_position.y = top_border_limit
		
	if (global_position.y > bottom_border_limit):
		direction.y = -direction.y
		global_position.y = bottom_border_limit


func _on_player_catch_body_entered(body):
	queue_free()
	GameManager.player_node.ball_gathered = true
