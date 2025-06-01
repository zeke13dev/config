(* A simple OCaml program to test LSP and syntax highlighting *)

(* Define a recursive function *)
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)

(* Define a function using pattern matching *)
let describe_number = function
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"

(* Entry point *)
let () =
  let n = 5 in
  let result = factorial n in
  let description = describe_number n in
  Printf.printf "factorial %d = %d (%s)\n" n result description

