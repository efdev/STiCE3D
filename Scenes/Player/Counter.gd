extends Label

var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_setText()
	
func _setText():
	text = String(count)
