extends CharacterBody2D

#Instances Varriables
@onready var dash_delay = $DashDelay
@onready var ball = $Ball
@onready var icon = $Icon
@onready var camera_2d = $Camera2D

#Preload Scene Variables
const BALL = preload("res://Scenes/ball.tscn")

#Const Variables
const SPEED: float = 300.0
const ACCEL: float = 30.0
const DECCEL: float = 25.0
const JUMP_VELOCITY: float = -400.0
const DASH_DISTANCE: float = 15000.0

#State Variables
enum PLAYER_STATE {
	IDLE,
	KICK,
	DASH
}

var direction : Vector2 = Vector2.ZERO
var fixed_direction: Vector2 = Vector2(1,0)
var player_state = PLAYER_STATE.IDLE
var dash_stop_count = 0
var dash_stop_max = 4
var ball_gathered = true

func _ready():
	GameManager.player_node = self
	GameManager.camera_node = camera_2d

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction != Vector2.ZERO:
		fixed_direction = direction
		ball.position = icon.position + (direction * 32)
	
	match player_state:
		PLAYER_STATE.IDLE:
			player_state_idle()
		PLAYER_STATE.DASH:
			player_state_dash(delta)
			
	move_and_slide()

func player_state_idle():
	
	ball.visible = ball_gathered
	
	if (Input.is_action_just_pressed("dash")) and (dash_delay.time_left <= 0.0):
		player_state = PLAYER_STATE.DASH
		
	if (Input.is_action_just_pressed("kick")) and ball_gathered:
		ball_gathered = false
		var ball_instance = BALL.instantiate()
		GameManager.add_child(ball_instance)
		ball_instance.global_position = ball.global_position + (fixed_direction * 32)
		ball_instance.direction = fixed_direction
		
	
	# Horizontal Accel and Deccel Check
	if direction.x:
		velocity.x = move_toward(velocity.x,  direction.x * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, DECCEL)
	
	# Vertical Accel and Deccel Check	
	if direction.y:
		velocity.y = move_toward(velocity.y,  direction.y * SPEED, ACCEL)
	else:
		velocity.y = move_toward(velocity.y, 0, DECCEL)
		
func player_state_dash(delta):
	if dash_stop_count >= dash_stop_max:
		dash_stop_count = 0
		player_state = PLAYER_STATE.IDLE
		dash_delay.start()
		return
		
	velocity = Vector2.ZERO
	global_position += (fixed_direction * (DASH_DISTANCE / dash_stop_max)) * delta
	dash_stop_count += 1

func get_camera():
	return camera_2d
