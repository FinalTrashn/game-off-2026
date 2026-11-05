@tool
extends EditorScript

const COUNT := 20
const SIZE := 2048  # 20 images ≈ 250 MB on disk, lower if you like


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://_loadtest")
	var crypto := Crypto.new()
	var total := SIZE * SIZE * 3

	for i in COUNT:
		# random noise doesn't compress, so it's slow to load
		var bytes := PackedByteArray()
		while bytes.size() < total:
			bytes.append_array(crypto.generate_random_bytes(65536))
		bytes.resize(total)

		var img := Image.create_from_data(SIZE, SIZE, false, Image.FORMAT_RGB8, bytes)
		img.save_png("res://_loadtest/noise_%02d.png" % i)

	EditorInterface.get_resource_filesystem().scan()
	print("Ballast created in res://_loadtest")
