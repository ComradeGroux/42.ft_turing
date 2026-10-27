open Types

let init_machine(filepath: string) : turing =
	let json = Machine_parser.extract_result_or_exit (Machine_parser.extract_json filepath) in
	let name = Machine_parser.extract_result_or_exit (Machine_parser.get_name json) in
	let alphabet = Machine_parser.extract_result_or_exit (Machine_parser.get_alphabet json) in
	let blank = Machine_parser.extract_result_or_exit (Machine_parser.get_blank json) in
	let states = Machine_parser.extract_result_or_exit (Machine_parser.get_states json) in
	let initial = Machine_parser.extract_result_or_exit (Machine_parser.get_initial json) in
	let finals = Machine_parser.extract_result_or_exit (Machine_parser.get_finals json) in
	let transitions = Machine_parser.extract_result_or_exit (Machine_parser.get_transitions json) in
	{
		name = name;
		alphabet = alphabet;
		blank = blank;
		states = states;
		initial = initial;
		finals = finals;
		transitions = transitions
	}