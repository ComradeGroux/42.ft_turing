class turing (filepath: string) =
	let json = Parser.extract_json filepath in
	let name = Parser.get_name json in
	let alphabet = Parser.get_alphabet json in
	let blank = Parser.get_blank json in
	let states = Parser.get_states json in
	let initial = Parser.get_initial json in
	let finals = Parser.get_finals json in
	let transitions = Parser.get_transitions json in
	object (self)
		method name 		: string = name
		method alphabet		: string list = alphabet
		method blank 		: string = blank
		method states		: string list = states
		method initial		: string = initial
		method finals		: string list = finals
		method transitions	: (string * (string * string) list list) list = transitions

		method run (expr: string) = ()

	initializer print_endline "Machine initialized !"
end

