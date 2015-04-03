board = []

dim = [0, 1, 2]

filled = (cell) ->
	cell[0].innerHTML in ['X', 'O']

win = () ->
	status_bar = $('#status')[0]
	status_bar.style.color = "red"
	status_bar.innerHTML = "AI wins. Reload page to retry."
	disable_board()

tie = () ->
	status_bar = $('#status')[0]
	status_bar.style.color = "yellow"
	status_bar.innerHTML = "It's a tie.  Reload page to retry."
	disable_board()

disable_board = () ->
	for row in board
		do (row) ->
			for item in row
				do (item) ->
					item[0].onclick = false

check_threat = (rows, cols, me) ->
	threat = 0
	empty = undefined
	for i in [0, 1, 2]
		cell = board[rows[i]][cols[i]]
		owner = cell[0].innerHTML
		if owner == me
			return [0, undefined]
		if owner == '&nbsp;'
			empty = cell
		else threat += 1
	return [threat, empty]

ai_turn = (cell) ->
	if filled(cell)
		return
	cell[0].innerHTML = 'X'
	if not filled(board[1][1])
		board[1][1][0].innerHTML = 'O'
		return
	row = cell.row
	col = cell.col

	# check threats to win
	last_empty = undefined
	# check rows
	for i in _.difference(dim, row)
		[threat, empty] = check_threat([i, i, i], [0, 1, 2], 'X')
		if threat == 2
			empty[0].innerHTML = 'O'
			win()
			return
		last_empty = empty if threat and empty
	# check columns
	for j in _.difference(dim, col)
		[threat, empty] = check_threat([0, 1, 2], [j, j, j], 'X')
		if threat == 2
			empty[0].innerHTML = 'O'
			win()
			return
		last_empty = empty if threat and empty
	# check diagonal
	if row != col
		[threat, empty] = check_threat([0, 1, 2], [0, 1, 2], 'X')
		if threat == 2
			empty[0].innerHTML = 'O'
			win()
			return
		last_empty = empty if threat and empty
	if row != 2 - col
		[threat, empty] = check_threat([0, 1, 2], [2, 1, 0], 'X')
		if threat == 2
			empty[0].innerHTML = 'O'
			win()
			return
		last_empty = empty if threat and empty
	
	# check threats to lose
	# check diagonal
	if row == col
		[threat, empty] = check_threat([0, 1, 2], [0, 1, 2], 'O')
		if threat == 2
			empty[0].innerHTML = 'O'
			return
	last_empty = empty if empty and not last_empty
	# check reverse diagonal
	if row == 2 - col
		[threat, empty] = check_threat([0, 1, 2], [2, 1, 0], 'O')
		if threat == 2
			empty[0].innerHTML = 'O'
			return
	last_empty = empty if empty and not last_empty
	# check row
	[threat, empty] = check_threat([row, row, row], [0, 1, 2], 'O')
	if threat == 2
		empty[0].innerHTML = 'O'
		return
	last_empty = empty if empty and not last_empty
	# check column
	[threat, empty] = check_threat([0, 1, 2], [col, col, col], 'O')
	if threat == 2
		empty[0].innerHTML = 'O'
		return
	last_empty = empty if empty and not last_empty
	
	# no threats, take a corner most likely
	if last_empty
		last_empty[0].innerHTML = 'O'
	else
		tie()

@initialize = () ->
	for i in dim
		do (i) ->
			row = $.create('<tr>')
			$('#board').append(row[0])
			board_row = []
			board.push(board_row)
			for j in dim
				do (j) ->
					cell = $.create('<td>')
					cell.row = i
					cell.col = j
					cell[0].innerHTML = '&nbsp;'
					cell[0].onclick = do (cell) =>
						() => ai_turn(cell)
					row.append(cell[0])
					board_row.push(cell)
