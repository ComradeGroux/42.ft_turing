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
		method alphabet		: Core.Char.Set.t = alphabet
		method blank 		: char = blank
		method states		: Core.String.Set.t = states
		method initial		: string = initial
		method finals		: Core.String.Set.t = finals
		method transitions	: (string * char, transition) Core.Map.Poly.t = transitions

		method run (expr: string) = ()

	initializer print_endline "Machine initialized !"
end
