extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $BlinkTimer
@onready var lightning = preload("res://Scenes/lightning.tscn")
@onready var ghost_timer = $GhostTimer
@onready var teleport_sound: AudioStreamPlayer2D = $Teleport_Sound
@onready var hit_flash: AnimationPlayer = $Hit_Flash

@export var ghost_node:PackedScene


var on_ceiling = false

# Set these to match your game’s actual floor and ceiling Y positions
const FLOOR_Y = 936
const CEILING_Y = 305

func _input(event):
	if event.is_action_pressed("ui_accept"):
		teleport()	

func teleport():
	if on_ceiling:
		global_position.y = FLOOR_Y
		sprite.flip_v = false
		teleport_sound.play()
	else:
		global_position.y = CEILING_Y
		sprite.flip_v = true
		teleport_sound.play()
	
	on_ceiling = !on_ceiling
	sprite.visible = false
	timer.timeout.connect(_on_blink_timer)
	
	# Spawn lightning VFX
	var vfx = lightning.instantiate()
	vfx.position = global_position  # Spawn it at player's current location
	get_parent().add_child(vfx)
	if on_ceiling:
		vfx.position.y += 80
		vfx.position.x += 120
		vfx.scale.y = -1
	else:
		vfx.position.y -= 80 
		vfx.position.x += 120

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

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, $AnimatedSprite2D.scale)
	get_tree().current_scene.add_child(ghost)


func _on_ghost_timer_timeout():
	add_ghost()
