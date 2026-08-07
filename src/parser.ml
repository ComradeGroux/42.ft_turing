let check_filepath_validity filepath =
	if Sys.file_exists filepath then begin
		if Sys.is_directory filepath then begin
			prerr_endline ("Error: '" ^ filepath ^ "' is a directory");
			exit 1
		end
	end else begin
		prerr_endline ("Error: '" ^ filepath ^ "' does not exist");
		exit 1
	end

let extract_json filepath =
	try
		Yojson.Safe.from_file filepath
	with | _ -> (prerr_endline "Error: occurred during the reading of the file" ; exit 1)

let get_name json =
	try
		Yojson.Safe.Util.(json |> member "name" |> to_string)
	with _ -> (prerr_endline "Error in json: name: The key miss or was mistyped" ; exit 1)

let get_alphabet json =
	let alpha = try
		Yojson.Safe.Util.(json |> member "alphabet" |> (convert_each to_string))
	with _ -> (prerr_endline "Error in json: alphabet: The key miss or was mistyped" ; exit 1) in
	if Core.List.for_all alpha ~f:(fun a -> Core.String.length a == 1) == false then begin
		prerr_endline "Error in json: alphabet: Each value must be a string of length equal to 1";
		exit 1
	end else
		alpha

let get_blank json =
	let blank = try
		Yojson.Safe.Util.(json |> member "blank" |> to_string)
	with _ -> (prerr_endline "Error in json: blank: The key miss or was mistyped" ; exit 1) in
	if Core.List.exists (get_alphabet json) ~f:(fun b -> Core.String.equal b blank) == false then begin
		prerr_endline "Error in json: blank: The blank value must exist in the alphabet";
		exit 1
	end else
		blank

let get_states json = try
		Yojson.Safe.Util.(json |> member "states" |> (convert_each to_string))
	with _ -> (prerr_endline "Error in json: states: The key miss or was mistyped" ; exit 1)

let get_initial json =
	let initial = try
		Yojson.Safe.Util.(json |> member "initial" |> to_string)
	with _ -> (prerr_endline "Error in json: initial: The key miss or was mistyped" ; exit 1) in
	if Core.List.exists (get_states json) ~f:(fun i -> Core.String.equal i initial) == false then begin
		prerr_endline "Error in json: initial: The initial value must exist in the states";
		exit 1
	end else
		initial

let get_finals json =
	let finals = try
		Yojson.Safe.Util.(json |> member "states" |> (convert_each to_string))
	with _ -> (prerr_endline "Error in json: states: The key miss or was mistyped" ; exit 1) in
	let states = get_states json in
	if Core.List.for_all finals ~f:(fun f -> Core.List.exists states ~f:(fun s -> Core.String.equal f s)) == false then begin
		prerr_endline "Error in json: initial: The finals values must exist in the states";
		exit 1
	end else
		finals

let parse_transition json =
	try
		Yojson.Safe.Util.([
			("read"		, json |> member "read"		|> to_string) ;
			("to_state"	, json |> member "to_state"	|> to_string) ;
			("write"	, json |> member "write"	|> to_string) ;
			("action"	, json |> member "action"	|> to_string)])
	with _ -> (prerr_endline "Error in json: transition: A key miss or was mistyped" ; exit 1)

let check_transitions_state_keys transitions states =
	if Core.List.for_all transitions ~f:(fun (key, _) -> Core.List.exists states ~f:(fun s -> Core.String.equal s key)) == false then begin
		prerr_endline "Error in json: transition: The transition's keys must exist in the states";
		exit 1
	end

let rec check_transitions_state_value lst alphabet states =
	match lst with
	| [] -> ()
	| head::tail -> begin
		let rec check_transition_values l alphabet states =
			match l with
			| [] -> check_transitions_state_value tail alphabet states
			| (read, value)::t when Core.String.equal read "read" ->
				if Core.List.exists alphabet ~f:(fun c -> Core.String.equal c value) == false then begin
					prerr_endline "Error in json: transition: The read value must exist in the alphabet";
					exit 1
				end;
				check_transition_values t alphabet states
			| (state, value)::t when Core.String.equal state "to_state" ->
				if Core.List.exists states ~f:(fun s -> Core.String.equal s value) == false then begin
					prerr_endline "Error in json: transition: The to_state value must exist in the states";
					exit 1
				end;
				check_transition_values t alphabet states
			| (write, value)::t when Core.String.equal write "write" ->
				if Core.List.exists alphabet ~f:(fun c -> Core.String.equal c value) == false then begin
					prerr_endline "Error in json: transition: The write value must exist in the alphabet";
					exit 1
				end;
				check_transition_values t alphabet states
			| (action, value)::t when Core.String.equal action "action" ->
				if Core.String.equal value "LEFT" == false && Core.String.equal value "RIGHT" == false then begin
					prerr_endline "Error in json: transition: The action value must be either LEFT or RIGHT";
					exit 1
				end;
				check_transition_values t alphabet states
			| _ -> begin
				prerr_endline "Error in json: transition: Unknown key";
				exit 1
			end
		in check_transition_values head alphabet states
	end

let get_transitions json =
	let transitions = try
		Yojson.Safe.Util.(
			json |> member "transitions" |> to_assoc |>
			List.map (fun (state, rules_json) -> (state, convert_each parse_transition rules_json)))
	with _ -> (prerr_endline "Error in json: transition: The key miss or was mistyped" ; exit 1) in
	let states = get_states json in
	let alphabet = get_alphabet json in
	check_transitions_state_keys transitions states ;
	Core.List.iter transitions ~f:(fun (_, transition) -> check_transitions_state_value transition alphabet states);
	transitions

let check_number_arguments_and_help argv =
	let argc = Array.length argv in
	let print_help () =
		print_endline (	"usage: ft_turing [-h] jsonfile input\n\n"				^
						"positional arguments:\n"								^
						"    jsonfile      json description of the machine\n"	^
						"    input         input of the machine\n\n"			^
						"optional arguments:\n"									^
						"    -h, --help    show this help message and exit")
	in match argc with
	| 2
	| 3
	| 4 ->
		if Array.exists (fun x -> String.equal x "--help" || String.equal x "-h") argv then begin
			print_help () ; exit 0
		end else ()
	| 1
	| _ -> prerr_endline "Wrong number of arguments.\n" ; print_help () ; exit 1
