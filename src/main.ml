let () =
	let argv = Sys.argv in
	Parser.check_number_arguments_and_help argv ;

	let filepath = (Array.get argv 1) in
	Parser.check_filepath_validity filepath ;

	let input = Array.get argv 2 in
	let turing = new Machine.turing filepath in
	turing#run input ;
