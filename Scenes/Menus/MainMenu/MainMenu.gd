extends Control

signal optionsPressed
signal playPressed
signal nextPressed
signal previousPressed

var err : int

func _ready(): 
	err = $HBoxContainer/MenuButtons/Play.connect("button_down", self, "_playButtonPressed")
	err = $HBoxContainer/MenuButtons/Quit.connect("button_down", self, "_quitButtonPressed")
	err = $HBoxContainer/MenuButtons/Options.connect("button_down", self, "_optionsButtonPressed")
	err = $HBoxContainer/MenuButtons/GameModeButtons/PreviousGMode.connect("button_down", self, "_arrowLeftPressed")
	err = $HBoxContainer/MenuButtons/GameModeButtons/NextGMode.connect("button_down", self, "_arrowRightPressed")
	

func _selectItem(var id : int):
	$HBoxContainer/TabContainer/MinTiles.select(id)
	
func _addMinTilesItem(var ItemName : String, var ItemIcon : Texture):
	$HBoxContainer/TabContainer/MinTiles.add_item(ItemName, ItemIcon)

func _addOtherItem(var ItemName : String, var ItemIcon : Texture):
	$HBoxContainer/TabContainer/Other.add_item(ItemName, ItemIcon)
	
func _playButtonPressed() -> void:
	emit_signal("playPressed")

func _quitButtonPressed() -> void:
	Config._saveConfig()
	get_tree().quit()
	
func _optionsButtonPressed() -> void:
	emit_signal("optionsPressed")

func _arrowLeftPressed() -> void:
	emit_signal("previousPressed")

func _arrowRightPressed() -> void:
	emit_signal("nextPressed")

func _setPreviewPicture(var newPreviewTex : Texture) -> void:
	$HBoxContainer/HBoxContainer/GameModePreview.texture = newPreviewTex

func _setPreviewText(var newText : String) -> void:
	$HBoxContainer/HBoxContainer/GameModeName.text = newText
	
#func _addItems():
#	var IconTexture : Texture = load("res://Textures/new_noisetexture.tres")
#	$HBoxContainer/ItemList.add_item("Level_1", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_2", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_3", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_4", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_5", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_6", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_7", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_8", IconTexture)
#	$HBoxContainer/ItemList.add_item("Level_9", IconTexture)

func _setItemSelected(index):
	print(index)
