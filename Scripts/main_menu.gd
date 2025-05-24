extends Control

@onready var title_label: Label = $GameTitle
@onready var buttons := [
	$VBoxContainer/Play,
	$VBoxContainer/Options,
	$VBoxContainer/Exit
]

# Vibration/glitch settings
@export var vibration_strength := 2.0
@export var glitch_frequency := 0.1
@export var glitch_duration := 0.1
@export var burst_duration := 2.0
@export var burst_interval := 4.0

var original_title_text := ""
var original_title_pos := Vector2.ZERO
var is_glitching := false
var is_burst_active := false
var glitch_timer := 0.0
var burst_timer := 0.0

func _ready():
	original_title_text = title_label.text
	original_title_pos = title_label.position
	start_burst()

	for btn in buttons:
		btn.set_meta("original_text", btn.text)
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
		btn.mouse_exited.connect(_on_button_mouse_exited.bind(btn))


func _process(delta):
	if is_burst_active:
		# Vibrate title position
		title_label.position = original_title_pos + Vector2(
			randf_range(-vibration_strength, vibration_strength),
			randf_range(-vibration_strength, vibration_strength)
		)

		# Occasionally glitch text
		glitch_timer += delta
		if glitch_timer >= glitch_frequency and not is_glitching:
			start_glitch()

		# End burst after time
		burst_timer += delta
		if burst_timer >= burst_duration:
			stop_burst()
	else:
		title_label.position = original_title_pos

func start_burst():
	is_burst_active = true
	burst_timer = 0.0
	glitch_timer = 0.0

func stop_burst():
	is_burst_active = false
	title_label.position = original_title_pos
	title_label.text = original_title_text
	await get_tree().create_timer(burst_interval).timeout
	start_burst()

func start_glitch():
	is_glitching = true
	glitch_timer = 0.0
	$Glitch_Sound.play()
	title_label.text = get_glitched_text(original_title_text)
	await get_tree().create_timer(glitch_duration).timeout
	title_label.text = original_title_text
	is_glitching = false
	$Glitch_Sound.stop()

func get_glitched_text(base: String) -> String:
	var chars = base.split("")
	var glitch_chars = ["#", "%", "&", "@", "*", "!", "|", "=", "~", " "]
	for i in range(randi() % 3 + 1):
		var index = randi() % chars.size()
		chars[index] = glitch_chars[randi() % glitch_chars.size()]
	return "".join(chars)

func _on_button_mouse_entered(button: Button):
	if not button.has_meta("original_text"):
		return
	var original = button.get_meta("original_text")
	button.text = get_glitched_text(original)

	await get_tree().create_timer(glitch_duration).timeout
	# Always reset to original after glitch_duration
	button.text = original

func _on_button_mouse_exited(button: Button):
	if button.has_meta("original_text"):
		button.text = button.get_meta("original_text")

func _on_play_pressed():
	$Click_Sound.play()
	get_tree().change_scene_to_file("res://Scenes/Main Map.tscn")

func _on_play_mouse_entered():
	$"Hover_Sound".play()

func _on_options_pressed():
	$Click_Sound.play()

func _on_options_mouse_entered():
	$"Hover_Sound".play()

func _on_exit_pressed():
	$Click_Sound.play()
	get_tree().quit()

func _on_exit_mouse_entered():
	$"Hover_Sound".play()
