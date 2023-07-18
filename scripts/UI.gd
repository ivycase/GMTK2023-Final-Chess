extends Control

signal curtains_closed

@onready var background = get_node("Background")
@onready var display = get_node("HUD/GameInfo")
@onready var tutorial = get_node("HUD/Tutorial")
@onready var curtain = get_node("HUD/Curtain")

@export_multiline var tutorial_text = ""
@export var finale = false

var background_green = Color("81e39f")
var background_pink = Color("be81e3")
var speed_green = 0.2
var speed_pink = -0.2

var shifting = false
#var target = background_green
#var opposite_direction = Vector2(1, 0)
#var opposite_speed = -0.02
#var shift_interpolate = 0
var shift_time = 1


var current_color
var current_speed
var new_color = background_pink
#var new_direction = Vector2(-1, 0)
var new_speed = speed_pink

var shift_tween

var world_time = 1

func _ready():
	if finale: 
		open_curtains()
		display_message("The End!")
		
	tutorial.text = tutorial_text
	curtain.show()
	randomize()
	background.position.x -= background.size.x / randf_range(2, 5)
	background.position.y -= background.size.y / randf_range(2, 5)

	_read_current_bg_values()

func _read_current_bg_values():
	current_color = background.material.get_shader_parameter("color_shift")
	current_speed = background.material.get_shader_parameter("scrolling_speed")
	
func _process(delta):
	print(shift_tween)
	if shift_tween:
		background.material.set_shader_parameter("color_shift", current_color)
		background.material.set_shader_parameter("scrolling_speed", current_speed)
	else:
		world_time += delta / 10
		background.material.set_shader_parameter("world_time", world_time)
	
	
func bg_color_shift(shift_green, skip_tween=false):
	_read_current_bg_values()
	if shift_tween: 
		shift_tween.kill()
		shift_tween = null
	
	new_color = background_green if shift_green else background_pink
	new_speed = speed_green if shift_green else speed_pink
	if skip_tween:
		background.material.set_shader_parameter("color_shift", new_color)
		background.material.set_shader_parameter("scrolling_speed", new_speed)
		return
	
	shift_tween = create_tween().set_parallel(true)
	shift_tween.tween_property(self, "current_color", new_color, shift_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	shift_tween.tween_property(self, "current_speed", new_speed, shift_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await shift_tween.finished
	print("done")
	if shift_tween: 
		shift_tween.kill()
		shift_tween = null
	
func open_curtains(skip_tween=false):
	if skip_tween:
		curtain.get_node("CurtainLeft").position = Vector2(0, 0)
		curtain.get_node("CurtainRight").position = Vector2(296, 0)
		return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(curtain.get_node("CurtainLeft"), "position", Vector2(0, 0), 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(curtain.get_node("CurtainRight"), "position", Vector2(296, 0), 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
func close_curtains():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(curtain.get_node("CurtainLeft"), "position", Vector2(104, 0), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(2)
	tween.tween_property(curtain.get_node("CurtainRight"), "position", Vector2(192, 0), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(2)
	await tween.finished
	curtains_closed.emit()
	
func display_message(message):
	#var color = "db5aba" if team == Global.Team.PINK else "76d48f"
	var color = "e34f4f"
	var prefix = "[center][color=" + color + "]"
	display.text = prefix + message

func clear_message():
	display.text = ""
	
