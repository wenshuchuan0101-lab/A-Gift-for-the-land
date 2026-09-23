extends RefCounted

const CHAPTERS := [
	{
		"display_name": "Scene 1",
		"scene_path": "res://Demo_Level.tscn",
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
]


static func is_chapter_unlocked(_chapter_index: int) -> bool:
	return true
