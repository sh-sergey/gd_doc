extends WindowDialog

onready var editor_help = get_node("../TabContainer/EditorHelp")
onready var tree = get_node("Tree")
onready var doc = get_node("../DocData")
onready var text = get_node("../TabContainer/EditorHelp/TextPanel/Text")
var root
var types = {}

func _ready():
	tree.set_hide_root(true)
	show()
	tree_update()

func add_type(type, root):
	if (types.has(type)):
		return
	
	var inherits = doc.class_list[type].inherits
	
	var parent = root
	
	if (inherits):
		if (!types.has(inherits)):
			add_type(inherits, root)
		if (types.has(inherits)):
			parent = types[inherits]
	
	var item = tree.create_item(parent)
	item.set_metadata(0, type)
	item.set_text(0, type)
	item.set_tooltip(0, str(doc.class_list[type].brief_description))
	item.set_collapsed(true)
	
	types[type] = item

func tree_update():
	tree.clear()
	types.clear()
	root = tree.create_item()
	var keys = doc.class_list.keys()
	keys.sort()
	for p in keys:
		add_type(p, root)

func _on_Button_pressed():
	show()
	tree_update()

func text_print():
	editor_help.write_doc(doc.class_list[tree.get_selected().get_metadata(0)])

func _on_Tree_item_activated():
	text_print()
	hide()

func _on_Open_pressed():
	text_print()
	hide()


func _on_Cancel_pressed():
	hide()
