extends CanvasLayer

@onready var label := $Label

func show_text(text: String) -> void:
	label.modulate.a = 1.0  # Garante que está visível
	label.text = ""
	
	for i in range(text.length()):
		label.text += text[i]
		await get_tree().create_timer(0.03).timeout
	
	await get_tree().create_timer(1.0).timeout
	hide_text()

func hide_text() -> void:
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5)

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	show_text("Eu despertei sem nome. Nem tempo. Nem fome.\nSó o vazio lembra que ainda existo.")
