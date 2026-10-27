let () =
	let argv = Sys.argv in
	Parser.check_number_arguments_and_help argv ;

	Printer.print_banner ();

	let filepath = (Array.get argv 1) in
	Parser.check_filepath_validity filepath ;

	let machine = Machine.init_machine filepath in
	Printer.print_success ("Machine " ^ machine.name ^ " initialized !");
	Printer.print_machine machine;

	let input = Array.get argv 2 in
	Parser.check_tape_validity input machine.alphabet machine.blank;

	let tape = Tape.init_tape input in
	Printer.print_success "Tape initialized !";
	Printer.print_input_tape tape;

	Printer.print_start ();
	Machine.run machine tape;

	print_endline ""
