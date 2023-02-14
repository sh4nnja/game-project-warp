extends Node2D

#######################################
########## INITIALIZATION #############
#######################################
onready var tween: Node = $text/animation
onready var label: Node = $text

var mode: String
var color: Color

var minColor: float = 0.1
var maxColor: float = 1

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _enter_tree():
	label = get_node("text")
	tween = get_node("text/animation")

func _ready():
	showCT(mode, color)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func showCT(sMode: String, sColor: Color) -> void:
	var cCrit: Array = ["Majestic", "Sheesh", "Fantastic", "Marvelous", "Noice"]
	var cNorm = ["Great", "Cool", "Burn", "Hot"]
	var cDamaged = ["Hit", "Ouch", "Watch Out"]
	var cScrap = ["Scrap Gathered!", "Got Scrap!", "Obtained Scrap"]
	label.rect_pivot_offset = label.rect_size / 2
	label.self_modulate = sColor
	match sMode:
		"Normal": 
			tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.text = cNorm[lib.generateRandomNumber(0, 0, "randomInt", false) % cNorm.size()]
		"Critical": 
			tween.interpolate_property(label, "rect_scale", label.rect_scale * 2, label.rect_scale,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.text = cCrit[lib.generateRandomNumber(0, 0, "randomInt", false) % cCrit.size()]
		"Damaged": 
			tween.interpolate_property(label, "rect_scale", label.rect_scale / 2, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.text = cDamaged[lib.generateRandomNumber(0, 0, "randomInt", false) % cDamaged.size()]
		"Scrap":
			tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale / 2, 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.text = cScrap[lib.generateRandomNumber(0, 0, "randomInt", false) % cScrap.size()]
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	hide()
	queue_free()
