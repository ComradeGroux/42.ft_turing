let extract_action action =
	match action with
	| Types.Left -> "LEFT"
	| Types.Right -> "RIGHT"

let rule read to_state write action : Yojson.Safe.t = `Assoc [("read", `String (Core.String.of_char read));("to_state", `String to_state);("write", `String (Core.String.of_char write));("action", `String (extract_action action))]

let sweep state_name characters direction =
	List.map (fun c -> rule c state_name c direction) characters

let find_hash : Names.rules =
	let characters = List.filter (fun c -> c <> Encoding.zone_delimiter) Encoding.tape_chars in
	(
		Names.find_hash,
		(rule Encoding.zone_delimiter Names.reg Encoding.zone_delimiter Left)::(sweep Names.find_hash characters Right)
	)

let reg : Names.rules =
	(
		Names.reg,
		List.map (fun c -> (rule c (Names.create_seek_name c) c Right)) Encoding.universe
	)

let seek : Names.rules list =
	let seek_x c : Names.rules =
		let seek_name = Names.create_seek_name c in
		(
			seek_name,
			(rule Encoding.head_position (Names.create_read_name c) Encoding.head_position Right)::
			(sweep seek_name (List.filter (fun c -> c <> Encoding.head_position) Encoding.tape_chars) Right)
		)
	in
	List.map (fun c -> seek_x c) Encoding.universe

let read : Names.rules list =
	let read_x c : Names.rules =
		let read_name = Names.create_read_name c in
		(
			read_name,
			List.map (fun x -> (rule x (Names.create_back_name c x) x Left)) Encoding.universe
		)
	in List.map (fun c -> read_x c) Encoding.universe

let back : Names.rules list =
	let back_x x c : Names.rules =
		let back_name = Names.create_back_name x c in
		(
			back_name,
			(rule Encoding.universal_blank (Names.create_match_name x c) Encoding.universal_blank Right)::
			(sweep back_name Encoding.tape_chars Left)
		)
	in
	List.concat_map (fun x -> List.map (fun c -> back_x x c) Encoding.universe) Encoding.universe
