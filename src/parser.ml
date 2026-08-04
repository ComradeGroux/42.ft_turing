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
