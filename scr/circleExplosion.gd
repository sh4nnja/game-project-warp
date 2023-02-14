extends CPUParticles2D


#######################################
#### LOADING AND INITIALIZATION #######
#######################################
onready var selfDestruct = $selfDestruct

var cAmount: int

var minColor: float = 0.1
var maxColor: float = 1

#######################################
######## VIRTUAL CODES / START ########
#######################################
func _enter_tree():
	selfDestruct = get_node("selfDestruct")

func _ready():
	emit(cAmount)

#######################################
########## METHODS / SIGNALS ##########
#######################################
func emit(fxAmount: int) -> void:
	amount = fxAmount
	emitting = true

func _on_selfDestruct_timeout() -> void:
	queue_free()

