extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var noise = OpenSimplexNoise.new()

	# Configure
	noise.seed = randi()
	noise.lacunarity = 2.5
	noise.octaves = 2
	noise.period = 64.0
	noise.persistence = 1
	
	# Sample
#	print("Values:")
#	print(noise.get_noise_2d(1.0, 1.0))
#	print(noise.get_noise_3d(0.5, 3.0, 15.0))
#	print(noise.get_noise_4d(0.5, 1.9, 4.7, 0.0))
#	# This creates a 512x512 image filled with simplex noise (using the currently set parameters)
	var noise_image = noise.get_image(64, 64)
	noise_image.lock()
#	# You can now access the values at each position like in any other image
#	print(noise_image.get_pixel(10, 20))
	print(noise.get_noise_2d(10,21))
	for i in 64:
		for j in 64:
			print(noise.get_noise_2d(i,j))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
