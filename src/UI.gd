extends CanvasLayer

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

@onready var hp_bar = $Control/HPBar
@onready var stamina_bar = $Control/StaminaBar
@onready var contextual_label = %ContextualBG/ContextualLabel

signal item_consumed(index: int)

const ITEM_IMAGE_PATH = [
	preload("res://assets/items/energy_drink.png"),
	preload("res://assets/items/bandage.png"),
	preload("res://assets/items/medkit.png")
]
func _ready():
	GameState.found_a_key.connect(update_key_counter)
	GameState.hp_changed.connect(update_hp_counter)
	GameState.found_an_item.connect(update_inventory_panel)
	item_consumed.connect(GameState.item_consumption)
	
	update_hp_counter()
	update_key_counter()
	for i in len(GameState.inventory):
		if GameState.inventory[i] != GameState.Item.NOTHING:
			update_inventory_panel(int(GameState.inventory[i]), i)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		%Menu.visible = !%Menu.visible
		get_tree().paused = !get_tree().paused
	elif event.is_action_pressed("inventory_1"): use_item(0)
	elif event.is_action_pressed("inventory_2"): use_item(1)
	elif event.is_action_pressed("inventory_3"): use_item(2)

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)

func update_key_counter():
	%KeyCounter.text = str(GameState.keys, "/", GameState.NUM_OF_KEYS)
	
func update_inventory_panel(item_type: int, slot: int):
	%Inventory.get_child(slot).get_child(0).texture = ITEM_IMAGE_PATH[item_type]

func update_hp_counter():
	hp_bar.value = GameState.hp

func update_stamina_bar():
	stamina_bar.value = GameState.stamina
	
func _on_slot_1_gui_input(event):
	verify_input(event, 0)

func _on_slot_2_gui_input(event):
	verify_input(event, 1)

func _on_slot_3_gui_input(event):
	verify_input(event, 2)

func verify_input(event, index: int):
	if event is InputEventMouseButton and event.button_index == 1 and !event.pressed and GameState.inventory[index] != GameState.Item.NOTHING:
		use_item(index)

func use_item(index: int):
	%Inventory.get_child(index).get_child(0).texture = null
	item_consumed.emit(index)
	%ContextualBG.show()
	
#	%ContextualBG/ContextualLabel.text = str("Used an Item in Slot ", index+1)
	$Timer.start()
	await $Timer.timeout
	%ContextualBG.hide()
