extends CPUParticles2D


#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var selfDestruct = $selfDestruct

var minColor: float = 0.1
var maxColor: float = 1

var alive: int = 1
#######################################
######## VIRTUAL CODES / START ########
#######################################
func emit(fxAmount: int):
	amount = fxAmount
	emitting = true
	selfDestruct.start()

func _on_selfDestruct_timeout():
	queue_free()

