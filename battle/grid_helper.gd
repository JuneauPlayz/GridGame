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
