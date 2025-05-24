extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $BlinkTimer
var on_ceiling = false

# Set these to match your game’s actual floor and ceiling Y positions
const FLOOR_Y = 936
const CEILING_Y = 305

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space key by default
		teleport()

func teleport():
	if on_ceiling:
		global_position.y = FLOOR_Y
		sprite.flip_v = false
	else:
		global_position.y = CEILING_Y
		sprite.flip_v = true
	
	on_ceiling = !on_ceiling
	sprite.visible = false
	timer.timeout.connect(_on_blink_timer)

	# Trigger camera shake from parent
	get_parent().start_shake()


func _physics_process(delta):
	if not get_parent().game_running:
		$AnimatedSprite2D.play("Idle")
		pass
	else:
		$AnimatedSprite2D.play("Run")
		

func _on_blink_timer():
	sprite.visible = true
