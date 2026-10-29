let universal_blank = '~'
let rule_separator = '|'
let transition_separator = ';'
let zone_delimiter = '#'
let current = '^'
let left = 'L'
let right = 'R'

let preferred_state_chars = Core.String.to_list "ABCDEFGHIJKMNOPQSTUVWXYZabcdefghijklmnopqrstuvwxyz!\"$%&'()*+,-./:<=>?@[\\]_`{}"

let get_every_reserved_char =
	Core.Char.Set.of_list [
		universal_blank ;
		rule_separator ;
		transition_separator ;
		zone_delimiter ;
		left ;
		right
	]
