open Types

class turing (filepath: string) =
	let json = Parser.extract_result_or_exit (Parser.extract_json filepath) in
	let name = Parser.extract_result_or_exit (Parser.get_name json) in
	let alphabet = Parser.extract_result_or_exit (Parser.get_alphabet json) in
	let blank = Parser.extract_result_or_exit (Parser.get_blank json) in
	let states = Parser.extract_result_or_exit (Parser.get_states json) in
	let initial = Parser.extract_result_or_exit (Parser.get_initial json) in
	let finals = Parser.extract_result_or_exit (Parser.get_finals json) in
	let transitions = Parser.extract_result_or_exit (Parser.get_transitions json) in
	object (self)
		method name 		: string = name
		method alphabet		: symbol_set = alphabet
		method blank 		: symbol = blank
		method states		: state_set = states
		method initial		: state = initial
		method finals		: state_set = finals
		method transitions	: transition_table = transitions

		method run (expr: string) =
				let expr_list = Core.String.to_list expr in
				let input_tape = match expr_list with
					| [] -> assert false
					| head::tail -> { left = [] ; head = head ; right = tail }
				in ()

		method private print_tape t =
			let full_tape = (List.rev t.left) @ [t.head] @ t.right in
			let rec print_char_list lst =
				match lst with
				| [] -> ()
				| head::tail -> print_char head ; print_char_list tail
			in print_char_list full_tape

		method private move_left t =
			match t.left with
			| [] -> { left = [] ; head = blank ; right = t.head::t.right }
			| curr::tail -> { left = tail ; head = curr ; right = t.head::t.right }

		method private move_right t =
			match t.right with
			| [] -> { left = t.head::t.left ; head = blank ; right = [] }
			| curr::tail -> { left = t.head::t.left ; head = curr ; right = tail }

	initializer print_endline ("Machine " ^ self#name ^ " initialized !")
end
