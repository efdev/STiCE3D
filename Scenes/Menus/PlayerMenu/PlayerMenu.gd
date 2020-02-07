extends Control

signal continuePressed
signal optionsPressed
signal quitPressed

var err: int

func _ready():
	err = $VBoxContainer/Continue.connect("pressed", self, "_continuePressed")
	err = $VBoxContainer/Options.connect("pressed", self, "_optionsPressed")
	err = $VBoxContainer/Quit.connect("pressed", self, "_quitPressed")

func _continuePressed() -> void:
	emit_signal("continuePressed")
	
func _optionsPressed() -> void:
	emit_signal("optionsPressed")

func _quitPressed() -> void:
	emit_signal("quitPressed")
