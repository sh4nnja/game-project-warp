extends CPUParticles2D


#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var selfDestruct = $selfDestruct

var rAmount: int
var rScale: int

var minColor: float = 0.1
var maxColor: float = 1

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _enter_tree():
	selfDestruct = get_node("selfDestruct")

func _ready():
	emit(rAmount, rScale)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func emit(fxAmount: int, fxScale: int) -> void:
	amount = fxAmount
	emitting = true
	scale_amount = fxScale

func _on_selfDestruct_timeout() -> void:
	queue_free()
