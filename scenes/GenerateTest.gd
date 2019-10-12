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
	
	add_child(generated)
	
	var room = layout_gen.room_manager.get_room("4_WAY")
	
	for y in range(-4, 5):
		var toPrint = ""
		for x in range(-4, 5):
			var pos = Vector2(x, y)
			var tileData = room.get_tile(pos)
			if tileData.wallTile == "none":
				if tileData.floorTile == "base":
					toPrint += "1"
				elif tileData.floorTile == "base2":
					toPrint += "2"
				else:
					toPrint += "P"
			else:
				toPrint += tileData.wallTile[0]
		print(toPrint)
	