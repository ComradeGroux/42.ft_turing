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
			in
			let rec loop tape state =
				if Core.Set.mem self#finals state then begin
					self#print_tape tape;
					print_endline "";
					print_endline ("Final state reached: " ^ state)
				end	else
						let transition = Core.Map.find self#transitions (state, tape.head)
						in match transition with
						| None ->  prerr_endline (
								"Error: machine blocked: no transition for (" ^
								state ^ ", " ^ String.make 1 tape.head ^ ")"
							); exit 1
						| Some v -> begin
								self#print_tape tape;
								print_string " >>>>> Transition: ";
								self#print_transition state v;
								print_endline "";
								let tape = { tape with head = v.write } in
								let updated_tape = match v.action with
									| Left -> self#move_left tape
									| Right -> self#move_right tape
								in
								loop updated_tape v.to_state
							end

			in loop input_tape self#initial

		method private print_tape t =
			let rec print_char_list lst =
				match lst with
				| [] -> ()
				| head::tail -> print_char head; print_char_list tail
			in print_char '[';
			print_char_list (List.rev t.left);
			print_string ("<" ^ String.make 1 t.head ^ ">");
			print_char_list t.right;
			print_char ']'

		method private print_transition (state: state) (t: transition) =
			let action = match t.action with
			| Right -> "RIGHT"
			| Left -> "LEFT"
			in
			print_string (
				"(" ^ state ^ ", " ^ 
				String.make 1 t.read ^ ") -> (" ^
				t.to_state ^ ", " ^ String.make 1 t.write ^
				", " ^ action ^ ")"
			)

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
