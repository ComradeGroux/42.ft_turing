let print_help () =
		print_endline (	"usage: ft_turing [-h] jsonfile input\n\n"				^
						"positional arguments:\n"								^
						"    jsonfile      json description of the machine\n"	^
						"    input         input of the machine\n\n"			^
						"optional arguments:\n"									^
						"    -h, --help    show this help message and exit")

let print_error (error: string) =
  prerr_endline ("Error: " ^ error)
