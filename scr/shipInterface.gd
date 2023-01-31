extends Node2D

#######################################
########## INITIALIZATION #############
#######################################
onready var ammoCount: Node = $ammoCount
onready var animation: Node = $userInterfaceLayer/userInterface/animation

#######################################
######## VIRTUAL CODES / START ########
#######################################

#######################################
########## METHODS / SIGNALS ##########
#######################################
func updateAmmoCount(value: float, maxValue: float) -> void:
	ammoCount.max_value = maxValue
	ammoCount.value = value
	if value <= maxValue / 3:
		ammoCount.self_modulate = lib.lifeModulates[2]
	elif value <= maxValue / 2:
		ammoCount.self_modulate = lib.lifeModulates[1]
	else:
		ammoCount.self_modulate = lib.lifeModulates[0]

func death() -> void:
	animation.play("death")
