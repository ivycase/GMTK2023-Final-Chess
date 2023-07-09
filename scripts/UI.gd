extends Control

signal curtains_closed

@onready var background = get_node("Background")
@onready var display = get_node("HUD/GameInfo")
@onready var curtain = get_node("HUD/Curtain")

var background_green = Color("81e39f")
var background_pink = Color("be81e3")

var shifting = false
var target = background_green
var opposite_direction = Vector2(1, 0)
var shift_interpolate = 0
var speed = 0.05

func _ready():
	randomize()
	background.position.x -= background.size.x / randf_range(2, 5)
	background.position.y -= background.size.y / randf_range(2, 5)
	
func _process(delta):
	if shifting && shift_interpolate <= 1:
		shift_interpolate += delta * speed
		
		var current_color = background.material.get_shader_parameter("color_shift")
		var new_color = current_color.lerp(target, shift_interpolate)
		background.material.set_shader_parameter("color_shift", new_color)
		
		var current_direction = background.material.get_shader_parameter("scroll_direction")
		var new_direction = current_direction.lerp(opposite_direction, shift_interpolate)
		background.material.set_shader_parameter("scroll_direction", new_direction)
	
func bg_color_shift(shift_green):
	shifting = true
	target = background_green if shift_green else background_pink
	opposite_direction = -opposite_direction
	shift_interpolate = 0
	
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
	tween.tween_property(curtain.get_node("CurtainLeft"), "position", Vector2(104, 0), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(1)
	tween.tween_property(curtain.get_node("CurtainRight"), "position", Vector2(192, 0), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(1)
	await tween.finished
	curtains_closed.emit()
	
func display_message(message):
	#var color = "db5aba" if team == Global.Team.PINK else "76d48f"
	var color = "e34f4f"
	var prefix = "[center][color=" + color + "]"
	display.text = prefix + message

func clear_message():
	display.text = ""
	
