open Types

let extract_state_dict state dict =
	Core.Char.to_string (Core.Map.find_exn dict state)

let encode_alphabet (machine: turing) =
	Core.String.of_list (Core.Set.to_list machine.alphabet)
	
let encode_blank (machine: turing) =
	Core.String.of_char machine.blank

let encode_states (machine: turing) (dict) =
	let rec add_state states_lst acc =
		match states_lst with
		| head::tail -> add_state tail (acc ^ (extract_state_dict head dict))
		| _ -> acc
	in add_state (Core.Set.to_list machine.states) ""

let encode_initial (machine: turing) (dict) =
	extract_state_dict machine.initial dict

let encode_finals (machine: turing) (dict) =
	let rec add_state states_lst acc =
		match states_lst with
		| head::tail -> add_state tail (acc ^ (extract_state_dict head dict))
		| _ -> acc
	in add_state (Core.Set.to_list machine.finals) ""

let encode_transitions (machine: turing) (dict) =
	let extract_action action =
		match action with
		| Left -> Core.String.of_char Encoding.left
		| Right -> Core.String.of_char Encoding.right
	in let add_transi transi =
		match transi with
		| ((st, ch), tr) ->
			(extract_state_dict st dict) ^
			(Core.String.of_char tr.read) ^
			(extract_state_dict tr.to_state dict) ^
			(Core.String.of_char tr.write) ^
			(extract_action tr.action)
	in let entries_lst = Core.Map.to_alist machine.transitions
	in let check_if_last_one t =
		match t with
		| head::tail -> Core.String.of_char Encoding.transition_separator
		| _ -> ""
	in let rec for_each_transi transi_lst acc = begin
		match transi_lst with
		| head::tail -> for_each_transi tail (acc ^ add_transi head ^ check_if_last_one tail)
		| _ -> acc
	end
	in for_each_transi entries_lst ""

let build_states_dict (machine : turing) =
	let forbidden_chars = Core.Set.union machine.alphabet (Core.Char.Set.singleton machine.blank) in
	let forbidden_chars = Core.Set.union Encoding.get_every_reserved_char forbidden_chars in

	let available_chars = Core.List.filter Encoding.preferred_state_chars ~f:(fun c -> not (Core.Set.mem forbidden_chars c)) in

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
