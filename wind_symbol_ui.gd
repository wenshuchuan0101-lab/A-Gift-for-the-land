extends CanvasLayer

const SYMBOL_TEXTURE: Texture2D = preload("res://art/ui/wind_symbol.png")
const WIDTH_RATIO := 0.15
const MAX_WIDTH := 280.0

var symbol_rect: TextureRect


func _ready() -> void:
	layer = 100
	_symbol_rect()
	get_viewport().size_changed.connect(_layout_symbol)
	_layout_symbol()


func _symbol_rect() -> void:
	symbol_rect = TextureRect.new()
	symbol_rect.texture = SYMBOL_TEXTURE
	symbol_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	symbol_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	symbol_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(symbol_rect)


func _layout_symbol() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var width := minf(viewport_size.x * WIDTH_RATIO, MAX_WIDTH)
	var height := width * SYMBOL_TEXTURE.get_height() / SYMBOL_TEXTURE.get_width()
	symbol_rect.size = Vector2(width, height)
	symbol_rect.position = Vector2((viewport_size.x - width) * 0.5, 0.0)
