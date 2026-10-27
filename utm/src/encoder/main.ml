let () =
	let argv = Sys.argv in
	Parser.check_number_argument argv ~len:3;
	let filepath = (Array.get argv 1) in
	Parser.check_filepath_validity filepath ;
	let input = Array.get argv 2 in
	let machine = Machine.init_machine filepath in
	print_endline ((Encode.encode_machine machine) ^ input)
