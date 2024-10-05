extends Node2D

# Daftar bahan makanan dan metode memasak
var ingredients = ["tomato", "onion", "garlic", "carrot", "pepper", "lettuce", 
				   "chicken", "beef", "fish", "bread", "cheese", "egg", 
				   "salt", "sugar", "butter", "milk"]

var cooking_methods = ["grilled", "boiled", "fried", "steamed", "baked", "roasted"]

# Variabel game
var current_ingredient = ""
var current_method = ""
var player_input = ""
var score = 0
var round = 1
var max_rounds = 5
var time_limit = 4.0  # Waktu maksimal untuk menampilkan pesanan
var time_left = time_limit

# Referensi ke UI (Label dan LineEdit)
onready var ingredient_label = $IngredientLabel
onready var input_field = $InputField
onready var score_label = $ScoreLabel
onready var timer_label = $TimerLabel

# Fungsi untuk memulai game
func _ready():
	randomize()
	start_new_round()

# Fungsi untuk memulai ronde baru
func start_new_round():
	if round <= max_rounds:
		# Pilih bahan makanan dan metode memasak secara acak
		current_ingredient = ingredients[randi() % ingredients.size()]
		current_method = cooking_methods[randi() % cooking_methods.size()]
		
		# Tampilkan pesanan
		ingredient_label.text = "Order " + str(round) + ": " + current_ingredient + " (" + current_method + ")"
		player_input = ""
		input_field.text = ""
		input_field.grab_focus()  # Fokus ke input player
		time_left = time_limit
		
		# Mulai timer untuk menghilangkan tulisan setelah 4 detik
		var hide_timer = Timer.new()
		hide_timer.set_wait_time(4)
		hide_timer.set_one_shot(true)
		add_child(hide_timer)
		hide_timer.start()
		hide_timer.connect("timeout", self, "_on_hide_ingredient")
	else:
		end_game()

# Fungsi untuk menyembunyikan teks setelah 4 detik
func _on_hide_ingredient():
	ingredient_label.text = "Order " + str(round) + ": ???"  # Hilangkan pesanan

# Update timer setiap frame
func _process(delta):
	if round <= max_rounds:
		time_left -= delta
		timer_label.text = "Time left: " + str(round(time_left, 2))
		
		# Jika waktu habis, pindah ke ronde berikutnya
		if time_left <= 0:
			next_round(False)

# Fungsi untuk mengecek input player
func _on_InputField_text_entered(new_text):
	player_input = new_text.lower()
	
	# Periksa apakah player mengetik bahan dan metode memasak dengan benar
	if player_input == (current_ingredient + " " + current_method).lower():
		next_round(True)
	else:
		next_round(False)

# Pindah ke ronde berikutnya
func next_round(correct):
	if correct:
		score += 1
		score_label.text = "Score: " + str(score)
		ingredient_label.text = "Correct!"
	else:
		ingredient_label.text = "Wrong! The correct order was '" + current_ingredient + " (" + current_method + ")'."
	
	round += 1
	yield(get_tree().create_timer(1.0), "timeout")  # Tunggu 1 detik sebelum lanjut ke ronde berikutnya
	start_new_round()

# Fungsi akhir permainan
func end_game():
	ingredient_label.text = "Game Over! Final Score: " + str(score) + "/" + str(max_rounds)
	input_field.editable = false  # Hentikan input player
	timer_label.text = ""
