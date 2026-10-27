open Types

let preferred_state_chars =
	Core.String.to_list "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"

let encode_alphabet (machine: turing) =
	Core.String.of_list (Core.Set.to_list machine.alphabet)
	
let encode_blank (machine: turing) =
	Core.String.of_char machine.blank

let encode_states (machine: turing) (dict) =
	""

let encode_initial (machine: turing) (dict) =
	Core.Char.to_string (Core.Map.find_exn dict machine.initial)

let encode_finals (machine: turing) (dict) =
	""

let encode_transitions (machine: turing) (dict) =
	""

let build_states_dict (machine : turing) =
	let forbidden_chars = Core.Set.union machine.alphabet (Core.Char.Set.singleton machine.blank) in
	let forbidden_chars = Core.Set.union Encoding.get_every_reserved_char forbidden_chars in

	let available_chars = Core.List.filter preferred_state_chars ~f:(fun c -> not (Core.Set.mem forbidden_chars c))	in

	let states = Core.Set.to_list machine.states in
	let state_count = Core.List.length states in
	let available_count = Core.List.length available_chars in

	if state_count > available_count then
		failwith (Core.Printf.sprintf "Not enough available characters : %d states, %d characters" state_count available_count);

	let assigned_chars = Core.List.take available_chars state_count in
	Core.Map.of_alist_exn (module Core.String) (Core.List.map2_exn states assigned_chars ~f:(fun state c -> state, c))

let encode_machine (machine: turing) =
	let str = "" in
	let dict = build_states_dict machine in
	let str_alpha = str ^ (encode_alphabet machine) in
	let str_blank = str_alpha ^ Core.String.of_char Encoding.rule_separator ^ (encode_blank machine) in
	let str_states = str_blank ^ Core.String.of_char Encoding.rule_separator ^ (encode_states machine dict) in
	let str_initial = str_states ^ Core.String.of_char Encoding.rule_separator ^ (encode_initial machine dict) in
	let str_finals = str_initial ^ Core.String.of_char Encoding.rule_separator ^ (encode_finals machine dict) in
	let str_transitions = str_finals ^ Core.String.of_char Encoding.rule_separator ^ (encode_transitions machine dict) in
	let str_encoded = str_transitions ^ Core.String.of_char Encoding.zone_delimiter in
	str_encoded
