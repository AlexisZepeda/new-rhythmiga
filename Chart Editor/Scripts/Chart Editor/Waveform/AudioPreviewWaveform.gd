class_name AudioPreviewWaveform
extends ColorRect

const COLOR = Color.DARK_GRAY
const SCALE_LIMIT: int = 5

var preview: RMAudioStreamPreview
var preview_len: float
var loaded = false

var original_size_x: float = 1152.0
var zoom_scale: int = 1

var image_length: float = 0.0


func _ready():
	#setup(stream)
	original_size_x = get_rect().size.x


func setup(param_stream: AudioStream):
	if not RMAudioStreamPreviewGenerator.preview_updated.is_connected(_on_preview_updated):
		RMAudioStreamPreviewGenerator.preview_updated.connect(_on_preview_updated)
		preview = RMAudioStreamPreviewGenerator.generate_preview(param_stream)
		preview_len = float(preview.get_length())


func change_length(length: int) -> void:
	custom_minimum_size.x = length


func _draw_preview():
	#print("_draw_preview")
	
	var rect = get_rect()
	#print("rect size %s" % rect.size)
	#print("preview length %s" % preview_len)
	var size_preview = rect.size
	
	for i in range(0, size_preview.x):
		var ofs = i * preview_len / size_preview.x
		var ofs_n = (i+1) * preview_len / size_preview.x
		var maxi_preview = preview.get_max(ofs, ofs_n) * 0.5 + 0.5
		var mini_preview = preview.get_min(ofs, ofs_n) * 0.5 + 0.5
		
		draw_line(Vector2(i+1, size_preview.y*0.05 + mini_preview * size_preview.y*0.9), Vector2(i+1, size_preview.y*0.05 + maxi_preview * size_preview.y*0.9), COLOR, 1, false)


func _on_preview_updated(e):
	if e:
		loaded = true
		queue_redraw()


func _draw():
	if loaded:
		_draw_preview()
