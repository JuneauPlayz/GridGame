extends Node

var grid_arr = []

func setup_grid(arr):
	grid_arr = arr

func get_col(col):
	var column = []
	for row in grid_arr:
		if col < row.size():
			column.append(row[col])
	return column

func get_row(row):
	if row >= 0 and row < grid_arr.size():
		return grid_arr[row]
	return []

func get_diagonal(num):
	var diagonal = []
	var rows = grid_arr.size()
	if rows == 0:
		return diagonal

	var cols = grid_arr[0].size()

	if num == 1:
		# Top-left to bottom-right
		for i in range(min(rows, cols)):
			diagonal.append(grid_arr[i][i])
	elif num == 2:
		# Top-right to bottom-left
		for i in range(min(rows, cols)):
			diagonal.append(grid_arr[i][cols - 1 - i])
	
	return diagonal

func get_mid():
	if grid_arr.size() == 0:
		return null  # safety check
	
	var mid_row = grid_arr.size() / 2
	var mid_col = grid_arr[0].size() / 2

	return grid_arr[mid_row][mid_col]

func get_mid_block():
	var rows = grid_arr.size()
	if rows == 0:
		return []

	var cols = grid_arr[0].size()
	var mid_blocks = []

	if rows % 2 == 0 and cols % 2 == 0:
		# Even grid: return 2x2 center
		var r_start = rows / 2 - 1
		var c_start = cols / 2 - 1
		for r in range(r_start, r_start + 2):
			for c in range(c_start, c_start + 2):
				mid_blocks.append(grid_arr[r][c])
	else:
		# Odd grid: return 3x3 center
		var r_start = rows / 2 - 1
		var c_start = cols / 2 - 1
		for r in range(r_start, r_start + 3):
			for c in range(c_start, c_start + 3):
				if r >= 0 and r < rows and c >= 0 and c < cols:
					mid_blocks.append(grid_arr[r][c])

	return mid_blocks
	
func get_half(side):
	var rows = grid_arr.size()
	if rows == 0:
		return []

	var cols = grid_arr[0].size()
	var result = []

	match side:
		"top":
			for r in range(rows / 2):
				for c in range(cols):
					result.append(grid_arr[r][c])
		"bottom":
			for r in range(rows / 2, rows):
				for c in range(cols):
					result.append(grid_arr[r][c])
		"left":
			for r in range(rows):
				for c in range(cols / 2):
					result.append(grid_arr[r][c])
		"right":
			for r in range(rows):
				for c in range(cols / 2, cols):
					result.append(grid_arr[r][c])
		_:
			push_warning("Invalid side: " + side)

	return result
	
func get_outer_ring() -> Array:
	var result = []
	var rows = grid_arr.size()
	var cols = grid_arr[0].size()

	for c in range(cols):
		result.append(grid_arr[0][c])            # top row
		result.append(grid_arr[rows - 1][c])      # bottom row

	for r in range(1, rows - 1):
		result.append(grid_arr[r][0])            # left column
		result.append(grid_arr[r][cols - 1])      # right column

	return result

func get_middle_ring() -> Array:
	var result = []
	var start = 1
	var end = grid_arr.size() - 2  # 4 for 6x6

	# Top and bottom of middle ring
	for c in range(start, end + 1):
		result.append(grid_arr[start][c])       # top of middle ring
		result.append(grid_arr[end][c])         # bottom of middle ring

	# Left and right sides of middle ring
	for r in range(start + 1, end):
		result.append(grid_arr[r][start])       # left of middle ring
		result.append(grid_arr[r][end])         # right of middle ring

	return result

func get_cross(x, y):
	var result = []
	for platform in get_row(y):
		result.append(platform)
	for platform in get_col(x):
		result.append(platform)
	return result
	
func get_sides(x, y) -> Array:
	var result = []
	var rows = grid_arr.size()
	var cols = grid_arr[0].size()

	for dy in range(-1, 2):  # -1, 0, 1
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue  # Skip center tile

			var nx = x + dx
			var ny = y + dy

			if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
				result.append(grid_arr[ny][nx])

	return result

func get_corner(corner: String):
	if not grid_arr or grid_arr.size() == 0:
		return null

	match corner:
		"top_left":
			return grid_arr[0][0]
		"top_right":
			return grid_arr[0][grid_arr[0].size() - 1]
		"bottom_left":
			return grid_arr[grid_arr.size() - 1][0]
		"bottom_right":
			return grid_arr[grid_arr.size() - 1][grid_arr[0].size() - 1]
		_:
			return null
