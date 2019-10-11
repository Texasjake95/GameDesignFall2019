extends Node

static func loadJson(fileLoc):
	var file : File = File.new();
	file.open(fileLoc, File.READ)

	var fileData = file.get_as_text()
	file.close()
	
	var result = JSON.parse(fileData)
	
	return result.get_result()
	
static func check(opcode : int, bit : int):
	return (opcode & bit) == bit
	
#Get a random element in the given array	
static func get_random(array: Array):
	array.shuffle()
	return array[0]
	
class WeightedArray:
	var array = []
	var totalWeight = 0
	
	func add(object, weight=1):
		array.append(WeightedObject.new(object, weight))
		totalWeight += weight
		array.sort_custom(WeightedObject, "compare")
	
	func getRandom(rng: RandomNumberGenerator = null):
		
		if rng:
			return _get(rng.randi_range(1, totalWeight))
		
		return _get(randi() % totalWeight + 1)
	
	func _get(weight):
		for object in array:
			if weight > object.weight:
				weight -= object.weight
			else:
				return object.object
			
		return array[-1].object
		
	func shuffle():
		var result = []
		var tW = self.totalWeight
		var indecies = range(array.size())

		while indecies.size() > 0:

			var rand = randi() % tW
			var i = 0
			
			while rand > array[indecies[i]].weight:
				rand -= array[indecies[i]].weight
				i += 1
			
			var object = array[indecies[i]]
			
			result.push_back(object.object)
			tW -= object.weight
			indecies.remove(i)
			
		return result
	
class WeightedObject:
	var object
	var weight
	
	func _init(object, weight):
		self.object = object
		self.weight = weight
		
	static func compare(w1, w2):
		return w1.weight < w2.weight