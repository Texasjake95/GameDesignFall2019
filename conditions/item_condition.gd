extends BaseCondition

class_name ItemCondition

var items = []

func addItem(item):
	items.push_back(item)
	
func removeItem(item):
	items.erase(item)
	if condition():
		fireEvent()

func conditionType():
	return "win" 

func condition():
	return items.size() == 0

