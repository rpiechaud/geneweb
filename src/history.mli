(* $Id: history.mli,v 5.4 2007-01-19 01:53:16 ddr Exp $ *)
(* Copyright (c) 1998-2007 INRIA *)

open Config;
open Def;
open Gwdb;

value file_name : config -> string;

value record : config -> base -> base_changed iper string -> string -> unit;
value notify : config -> base -> string -> unit;

value print : config -> base -> unit;
value print_search : config -> base -> unit;


(* Ajout pour l'API *)
value line_fields :
  string -> option (string * string * string * option string);
value rev_input_line :
  in_channel -> int -> (ref string * ref int) -> (string * int);
