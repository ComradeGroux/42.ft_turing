type rules = (string * Yojson.Safe.t list)

let find_hash = "find_hash"
let reg = "reg"
let seek_ = "seek_"
let read_ = "read_"
let back_ = "back_"
let match_ = "match_"

let create_seek_name c = seek_ ^ Core.String.of_char c

let create_read_name c = read_ ^ Core.String.of_char c

let create_back_name x c = back_ ^ Core.String.of_char x ^ "_" ^ Core.String.of_char c

let create_match_name x c = match_ ^ Core.String.of_char x ^ "_" ^ Core.String.of_char c
