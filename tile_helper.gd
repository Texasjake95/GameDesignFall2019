extends Node

class_name TileHelper
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


var tile_data = Dictionary()

func get_tile_data(floorTile, wallTile, entity):
	var key = [floorTile, wallTile, entity]
	if not tile_data.has(key):
		tile_data[key] = TileData.new(floorTile, wallTile, entity)
	
	return tile_data[key]


func _get_weighted_tile_array(arrayData):
	
	var ret = util.WeightedArray.new()
	
	for data in arrayData:
		var floorTile = data["floor"]
		var wallTile = data["wall"]
		var entity = data["entity"]
		var weight = util.get_or_default(data, "weight", 1)
		
		var tileData = get_tile_data(floorTile, wallTile, entity)
		ret.add(tileData, weight)
		
	return ret
	
func get_tile_provider(providerData):
	var type = providerData["type"]
	
	if type == "single":
		return SingleProvider.new(_get_weighted_tile_array(providerData["tiles"]))
		
	return null


class TileData:
	var floorTile
	var wallTile
	var entity

	func _init(floorTile, wallTile, entity):
		self.floorTile = floorTile
		self.wallTile = wallTile
		self.entity = entity

class TileProvider:
	
	func getTileData():
		pass
		
class SingleProvider:
	extends TileProvider
	var tiles
	
	func _init(tiles):
		self.tiles = tiles
	
	func getTileData():
		return tiles.getRandom()