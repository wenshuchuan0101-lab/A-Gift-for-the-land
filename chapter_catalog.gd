extends RefCounted

const CHAPTERS := [
	{
		"display_name": "Scene 1",
		"scene_path": "res://scenes/chapter1/scene_intro.tscn",
		"is_test": false,
	},
	{
		"display_name": "Scene 2",
		"scene_path": "res://scenes/testing/chapter_2_test.tscn",
		"is_test": true,
	},
	{
		"display_name": "Scene 3",
		"scene_path": "res://scenes/testing/chapter_3_test.tscn",
		"is_test": true,
	},
	{
		"display_name": "Scene 4 · 雅丹石林追逐",
		"scene_path": "res://scenes/chapter1/scene04_yadan_chase_empty.tscn",
		"is_test": false,
	},
]


static func is_chapter_unlocked(_chapter_index: int) -> bool:
	return true

