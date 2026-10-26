let () =
	let argv = Sys.argv in
	Parser.check_number_arguments_and_help argv ;

	let filepath = (Array.get argv 1) in
	Parser.check_filepath_validity filepath ;

	let turing = new Machine.turing filepath in
	let input = Array.get argv 2 in
	Parser.check_tape_validity input turing#alphabet turing#blank;

	turing#run input ;
