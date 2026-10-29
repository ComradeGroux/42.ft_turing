let normal_mode (json: string) (input: string) =
	Printer.print_banner ();

	Parser.check_filepath_validity json;

	let machine = Machine.init_machine json in
	Printer.print_success ("Machine " ^ machine.name ^ " initialized !");
	Printer.print_machine machine;

	Parser.check_tape_validity input machine.alphabet machine.blank;

	let tape = Tape.init_tape input in
	Printer.print_success "Tape initialized !";
	Printer.print_input_tape tape;

	Printer.print_start ();
	Machine.run machine tape;

	print_endline ""

let complexity_mode (json: string) (inputs_path: string) =
	Printer.print_banner ();

	Parser.check_filepath_validity json;

	let machine = Machine.init_machine json in
	Printer.print_success ("Machine " ^ machine.name ^ " initialized !");
	Printer.print_machine machine;

	let inputs = Parser.read_inputs inputs_path in
	let lengths = List.sort_uniq compare (List.map String.length inputs) in
	if List.length lengths < 3
		then begin
			Printer.print_error "Need inputs of at least 3 different lengths !";
			exit 1
		end;
	List.iter (
		fun i ->
			Parser.check_tape_validity i machine.alphabet machine.blank
	) inputs;

	let tapes = List.map Tape.init_tape inputs in
	Printer.print_success "All tape initialized !";

	(* Steps:
	-> Run machine in silence mode, return number of step. Set step limit to handle infinity loop.
	-> create tuple of (input len, step nb)
	-> use some math stuffs to guess time complexity
	-> profit
	*)

	print_endline ""


let () =
	let argv = Sys.argv in
	let res = Parser.check_number_arguments_and_help argv in
	match res with
	| Normal (json, input) -> normal_mode json input
	| Complexity (json, inputs) -> complexity_mode json inputs
