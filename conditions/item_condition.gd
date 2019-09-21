extends BaseCondition

class_name ItemCondition

var items = []

func addItem(item):
	print("Adding ITEM")
	items.push_back(item)
	
func removeItem(item):
	print("Removing ITEM")
	var index = items.find(item)
	items.remove(index)
	
func noItems():
	return not items.size() > 0

func conditionType():
	return "win" 

func condition():
	return not items.size() > 0

