extends Control

var gridContainer : GridContainer
var items : Array
var capacity := 20
var hoveredButton
var grabbedButton
var lastClickedMousePos : Vector2
var overTrash : bool
@export var CanSwapEmpty : bool
@export var MaxWeight := 0
@export var AllowOverWeight : bool
var IsOverWeight : bool
var currentWeight := 0

func _ready():
	gridContainer = $ScrollContainer/GridContainer
	populateButtons()
	$WeightValue.text = str(currentWeight) + "/" + str(MaxWeight)
	
func _process(delta):
	pass
	
func _input(event):
	$MouseArea.position = get_tree().root.get_mouse_position()
	if hoveredButton != null:
		if CanSwapEmpty:
			CheckForDrag()
		else:
			if hoveredButton.get("currentItem"):
				if hoveredButton.currentItem != null:
					CheckForDrag()
			
			
	if Input.is_action_just_released("interact") && $MouseArea/InventoryButton.visible:
		$MouseArea/InventoryButton.hide()
		if overTrash:
				DeleteButton(grabbedButton)
		grabbedButton = null
	
func CheckForDrag():
	if Input.is_action_just_pressed("interact"):
		grabbedButton = hoveredButton
		lastClickedMousePos = get_tree().root.get_mouse_position()
			
	if lastClickedMousePos.distance_to(get_tree().root.get_mouse_position()) > 2:
		if Input.is_action_just_pressed("interact"):
			if grabbedButton == null:
				grabbedButton = hoveredButton
			$MouseArea/InventoryButton.show()
			$MouseArea/InventoryButton.UpdateItem(grabbedButton.currentItem, 0)
		if Input.is_action_just_released("interact"):
			if overTrash:
				DeleteButton(grabbedButton)
			else :
					SwapButtons(grabbedButton, hoveredButton)
					$MouseArea/InventoryButton.hide()
					pass
	
func DeleteButton(button):
	items.remove_at(items.find(button.currentItem))
	reflowButtons()
	
func populateButtons():
	for i in capacity:
		var packedScene = ResourceLoader.load("res://addons/GGDK/InventorySystem/Scenes/inventory_button.tscn")
		var itemButton : Button = packedScene.instantiate()
		itemButton.connect("OnButtonClick", OnButtonClicked)
		$ScrollContainer/GridContainer.add_child(itemButton)
		
func SwapButtons(button1, button2):
	var button1Index = button1.get_index()
	var button2Index = button2.get_index()
	gridContainer.move_child(button1, button2Index)
	gridContainer.move_child(button2, button1Index)
		
func Add(item : Item):
	if MaxWeight > 0 :
		if currentWeight >= MaxWeight && !AllowOverWeight:
			return
	var currentItem = item.duplicate()
	for i in gridContainer.get_children():
		if i.currentItem != null:
			if i.currentItem.ID == item.ID:
				if i.currentItem.ID == currentItem.ID && i.currentItem.Quantity != i.currentItem.StackSize:
					if i.currentItem.Quantity + currentItem.Quantity > i.currentItem.StackSize:
						i.currentItem.Quantity = currentItem.StackSize
						currentItem.Quantity = -(currentItem.Quantity - i.currentItem.StackSize)
						UpdateButton(i.get_index(), i.currentItem)
					else:
						i.currentItem.Quantity += currentItem.Quantity
						currentItem.Quantity = 0
						UpdateButton(i.get_index(), i.currentItem)

	if currentItem.Quantity > 0:
		if currentItem.Quantity < currentItem.StackSize:
			for i in gridContainer.get_children():
				if i.currentItem == null:
					items.append(currentItem)
					UpdateButton(i.get_index(), currentItem)
					break
		else:
			for i in gridContainer.get_children():
				if i.currentItem == null:
					var tempItem = currentItem.duplicate()
					tempItem.Quantity = currentItem.StackSize
					items.append(tempItem)
					UpdateButton(i.get_index(), i.currentItem)
					currentItem.Quantity -= currentItem.StackSize
					Add(currentItem)
					break 
	reflowButtons()
	
func Remove(item : Item) -> bool:
	if canAfford(item):
		var currentItem = item
		for i in gridContainer.get_children():
			if i.currentItem != null:
				if i.currentItem.ID == currentItem.ID:
					if i.currentItem.Quantity - currentItem.Quantity < 0:
						currentItem.Quantity -= i.currentItem.Quantity
						i.currentItem.Quantity = 0
						UpdateButton(i.get_index(), i.currentItem)
					else:
						i.currentItem.Quantity -= currentItem.Quantity
						currentItem.Quantity = 0
						UpdateButton(i.get_index(), i.currentItem)
							
			if currentItem.Quantity <= 0:
				break
		var tempItems = items.duplicate()
		var offset = 0
		for i in tempItems.size():
			if items[i - offset].Quantity == 0:
				items.remove_at(i - offset)
				offset += 1
						
		reflowButtons()
		return true
	return false
		
	
	
func canAfford(item : Item) -> bool:
	var count : int
	for i in gridContainer.get_children():
		if i.currentItem != null:
			if i.currentItem.ID == item.ID:
				count += item.Quantity
	return count >= item.Quantity
	
	
func reflowButtons():
	currentWeight = 0
	for i in gridContainer.get_children():
		if i.currentItem == null:
			UpdateButton(i.get_index())
		else:
			if i.currentItem.Quantity > 0:
				UpdateButton(i.get_index(), i.currentItem)
				currentWeight += i.currentItem.Weight * i.currentItem.Quantity
			else:
				UpdateButton(i.get_index())
				
	$WeightValue.text = str(currentWeight) + "/" + str(MaxWeight)
	if(AllowOverWeight):
		IsOverWeight = currentWeight > MaxWeight
	if IsOverWeight:
		$WeightValue.add_theme_color_override("font_color", Color(1,0,0))
	else:
		$WeightValue.add_theme_color_override("font_color", Color(1,1,1))
				
	
func UpdateButton(index : int, item : Item = null):
	if gridContainer.get_child(index) == null:
		print("Error: Chilt At Index" +str(index) + "Is null")
		return
	gridContainer.get_child(index).UpdateItem(item, index)



func OnButtonClicked(index, currentItem : Item):
	if currentItem != null:
		currentItem.UseItem()


func _on_button_button_down():
	Add(ResourceLoader.load("res://Scenes/Resources/Item.tres"))
	pass # Replace with function body.


func _on_button_2_button_down():
	print(Remove(ResourceLoader.load("res://Scenes/Resources/Item.tres")))
	pass # Replace with function body.


func _on_mouse_area_area_entered(area):
	hoveredButton = area.get_parent()
	pass # Replace with function body.


func _on_mouse_area_area_exited(area):
	hoveredButton = null
	pass # Replace with function body.


func _on_trash_area_area_entered(area):
	overTrash = true
	pass # Replace with function body.


func _on_trash_area_area_exited(area):
	overTrash = false
	pass # Replace with function body.
