(* camlp4r *)
(* $Id: image.ml,v 4.5 2002-07-15 08:34:24 ddr Exp $ *)
(* Copyright (c) 2001 INRIA *)

open Util;
open Config;

value content cgi t len fname =
  do {
    if not cgi then Wserver.http "" else ();
    Wserver.wprint "Content-type: image/%s" t;
    Util.nl ();
    Wserver.wprint "Content-length: %d" len;
    Util.nl ();
    Wserver.wprint "Content-disposition: attachement; filename=%s"
      (Filename.basename fname);
    Util.nl ();
    Util.nl ();
    Wserver.wflush ();
  }
;

value print_image_type cgi fname itype =
  match try Some (open_in_bin fname) with [ Sys_error _ -> None ] with
  [ Some ic ->
      let buf = String.create 1024 in
      let len = in_channel_length ic in
      do {
        content cgi itype len fname;
        let rec loop len =
          if len == 0 then ()
          else do {
            let olen = min (String.length buf) len in
            really_input ic buf 0 olen;
            Wserver.wprint "%s" (String.sub buf 0 olen);
            loop (len - olen)
          }
        in
        loop len;
        close_in ic;
        True
      }
  | None -> False ]
;

value print_image_file cgi fname =
  List.exists
    (fun (suff, itype) ->
       if Filename.check_suffix fname suff ||
          Filename.check_suffix fname (String.uppercase suff) then
         print_image_type cgi fname itype
       else False)
    [(".png", "png"); (".jpg", "jpeg"); (".jpeg", "jpeg"); (".gif", "gif")]
;

value print_personal_image conf base p =
  match image_and_size conf base p (fun x y -> Some (1, 1)) with
  [ Some (True, f, _) ->
      if print_image_file conf.cgi f then () else incorrect_request conf
  | _ -> incorrect_request conf ]
;

value print_source_image conf f =
  let fname =
    if f.[0] = '/' then String.sub f 1 (String.length f - 1) else f
  in
let _ = do { Printf.eprintf "%s\n" fname; flush stderr; } in
  if fname = Filename.basename fname then
let _ = do { Printf.eprintf "%s\n" fname; flush stderr; } in
    let fname = source_image_file_name conf.bname fname in
let _ = do { Printf.eprintf "%s\n" fname; flush stderr; } in
    if print_image_file conf.cgi fname then () else incorrect_request conf
  else incorrect_request conf
;

value print conf base =
  match p_getenv conf.env "s" with
  [ Some f -> print_source_image conf f
  | None ->
      match find_person_in_env conf base "" with
      [ Some p -> print_personal_image conf base p
      | _ -> incorrect_request conf ] ]
;
