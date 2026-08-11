type action = LEFT | RIGHT

type transition = {
	read	: char;
	to_state: string;
	write	: char;
	action	: action
}

type error =
	| Json_error of string
	| Missing_field of string
	| Invalid_symbol of string
	| Blank_not_in_alphabet
	| Unknown_state of string
	| Initial_not_in_states
	| Finals_not_subset_of_states
	| Duplicate_transitions of string * char
	| Machine_blocked of string * char
	| Default_error of string
