extends Node2D

#######################################
########## INITIALIZATION #############
#######################################
onready var ammoCount: Node = $interface/ammoCount
onready var animation: Node = $animation

var locked: bool = true
#######################################
######## VIRTUAL CODES / START ########
#######################################

#######################################
########## METHODS / SIGNALS ##########
#######################################
func animateBar(play: bool):
	if play and !locked:
		locked = true 
		animation.play("radial")
	elif !play and locked: 
		locked = false
		animation.play_backwards("radial")

func updateAmmoCount(value: float, maxValue: float):
	ammoCount.max_value = maxValue
	ammoCount.value = value
	if value <= maxValue / 3:
		ammoCount.self_modulate = lib.lifeModulates[2]
	elif value <= maxValue / 2:
		ammoCount.self_modulate = lib.lifeModulates[1]
	else:
		ammoCount.self_modulate = lib.lifeModulates[0]
