extends Button

var currentItem : Item
var currentIcon
var currentLabel
var index

signal OnButtonClick(Index, item)

func _ready():
	currentIcon = $TextureRect
	currentLabel = $Label
	pass
	
func _process(delta):
	pass


func UpdateItem(item: Item, index : int):
	self.index = index
	currentItem = item
	if currentItem == null:
		currentIcon.texture = null
		currentLabel.text = ""
	else:
		if item.Quantity <= 0:
			currentIcon.texture = null
			currentLabel.text = ""
		else:
			currentIcon.texture = item.Icon
			currentLabel.text = str(item.Quantity)

func _on_area_2d_area_entered(area):
	pass # Replace with function body.


func _on_area_2d_area_exited(area):
	pass # Replace with function body.


func _on_button_down():
	emit_signal("OnButtonClick", index, currentItem)
	pass # Replace with function body.
