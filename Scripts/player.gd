extends CharacterBody2D

@onready var dash_delay = $DashDelay

const SPEED: float = 300.0
const ACCEL: float = 30.0
const DECCEL: float = 25.0
const JUMP_VELOCITY: float = -400.0
const DASH_DISTANCE: float = 15000.0

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

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction != Vector2.ZERO:
		fixed_direction = direction
	
	match player_state:
		PLAYER_STATE.IDLE:
			player_state_idle()
		PLAYER_STATE.DASH:
			player_state_dash(delta)
			
	move_and_slide()

func player_state_idle():
	
	if (Input.is_action_just_pressed("dash")) and (dash_delay.time_left <= 0.0):
		player_state = PLAYER_STATE.DASH
	
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
