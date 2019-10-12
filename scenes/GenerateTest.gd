extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var grammar = layout_gen.load_layout("res://test3.json")
	var generated : LayoutMap = layout_gen.generate_layout(grammar)
	#var generated : TileMap = TileMap.new()
	
	var tile_set = load("res://scenes/layout_tileset.tres")
	generated.set_tileset(tile_set)
	generated.set_cell_size(Vector2(30,30))
	
	var array = layout_gen.populate(generated, null) 
	var floors = array[0]
	floors.set_tileset(tile_set)
	floors.set_cell_size(Vector2(30,30))
	
	var walls = array[1]
	walls.set_tileset(tile_set)
	walls.set_cell_size(Vector2(30,30))
	add_child(floors)
	add_child(walls)