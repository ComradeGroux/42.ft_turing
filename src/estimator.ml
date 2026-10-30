open Types

let min_lengths = 3

(* True if there are at least min_lengths different lengths *)
let enough_lengths (lengths: tape_len list) : bool =
  List.length (List.sort_uniq compare lengths) >= min_lengths

let clean_data (data: time_data list) : time list =
  let filtered = List.filter_map (
    fun step -> match step with
    | Reject _ -> None
    | Accept s -> Some s
  ) data
  in
  if not (enough_lengths (List.map fst filtered))
    then begin
      Printer.print_error (
        "Need inputs of at least " ^ string_of_int min_lengths ^
        " different lengths after filtered !"
      );
      exit 1
    end;
  let sorted = List.sort (
    fun (l1, s1) (l2, s2) ->
      if l1 <> l2 then compare l1 l2 else compare s2 s1
  ) filtered
  in
  Core.List.remove_consecutive_duplicates
    ~which_to_keep:`First
    ~equal:(fun (l1, _) (l2, _) -> l1 = l2) sorted

(* data is (f(n), steps) *)
let linear_regression (data: (float * float) list) : (float * float) =
  (1., 1.)

let compute_error ()

let estimate (data: time_data list) =
  let cleaned = clean_data data
  in
  let complexities = List.map (
    fun c ->
      (* set f(n) and convert step to float *)
      let c_set = List.map (
        fun (len, steps) ->
          (Complexity.transform c (float_of_int len), float_of_int steps)
      ) cleaned
      in
      let thetas = linear_regression c_set in
      let error = compute_error in
      {
        bigO: c;
        m: fst thetas;
        b: snd thetas;
        error: error
      }
  ) Complexity.all
  in ()
