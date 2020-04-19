open Httpaf
open Base
open Lwt.Infix
open Httpaf_lwt_unix

module Arg = Caml.Arg
module Format = Caml.Format
module String = Caml.String

let print_string = Stdio.(Out_channel.output_string stdout)

let text = "CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......"

let text = Bigstringaf.of_string ~off:0 ~len:(String.length text) text


module Client = struct
  let print ~on_eof response response_body =
    match response with
    | { Response.status = `OK; _ } as response ->
      Format.fprintf Format.std_formatter "%a\n%!" Response.pp_hum response;
      let rec on_read bs ~off ~len =
        Bigstringaf.substring ~off ~len bs |> print_string;
        Body.schedule_read response_body ~on_read ~on_eof
      in
      Body.schedule_read response_body ~on_read ~on_eof;
    | response ->
      Format.fprintf Format.err_formatter "%a\n%!" Response.pp_hum response;
      Caml.exit 1
  ;;
end

module EchoServer = struct
  let echo_post reqd =
    Stdio.printf "fire";
    match Reqd.request reqd  with
    | { Request.meth = `POST; headers; _ } ->
      let response =
        let content_type =
          match Headers.get headers "content-type" with
          | None   -> "application/octet-stream"
          | Some x -> x
        in
        Response.create ~headers:(Headers.of_list ["content-type", content_type; "connection", "close"]) `OK
      in
      let request_body  = Reqd.request_body reqd in
      let response_body = Reqd.respond_with_streaming reqd response in
      let rec on_read buffer ~off ~len =
        Body.write_bigstring response_body buffer ~off ~len;
        Body.schedule_read request_body ~on_eof ~on_read;
      and on_eof () =
        Body.close_writer response_body
      in
      Body.schedule_read (Reqd.request_body reqd) ~on_eof ~on_read
    | _ ->
      let headers = Headers.of_list [ "connection", "close" ] in
      Reqd.respond_with_string reqd (Response.create ~headers `Method_not_allowed) ""
  ;;

  let error_handler ?request:_ error start_response =
    let response_body = start_response Headers.empty in
    begin match error with
    | `Exn exn ->
      Body.write_string response_body (Exn.to_string exn);
      Body.write_string response_body "\n";
    | #Status.standard as error ->
      Body.write_string response_body (Status.default_reason_phrase error)
    end;
    Body.close_writer response_body
  ;;
end

let request_handler (_ : Unix.sockaddr) = EchoServer.echo_post
let error_handler (_ : Unix.sockaddr) = EchoServer.error_handler

let main port =
  let listen_address = Unix.(ADDR_INET (inet_addr_loopback, port)) in
  Lwt.async (fun () ->
    Lwt_io.establish_server_with_client_socket
      listen_address
      (Server.create_connection_handler ~request_handler ~error_handler)
    >|= fun _server ->
      Stdio.printf "Listening on port %i and echoing POST requests.\n" port;
      Stdio.printf "To send a POST request, try one of the following\n\n";
      Stdio.printf "  echo \"Testing echo POST\" | dune exec examples/async/async_post.exe\n";
      Stdio.printf "  echo \"Testing echo POST\" | dune exec examples/lwt/lwt_post.exe\n";
      Stdio.printf "  echo \"Testing echo POST\" | curl -XPOST --data @- http://localhost:%d\n\n%!" port);
  let forever, _ = Lwt.wait () in
  Lwt_main.run forever
;;

let () =
  let port = ref 8080 in
  Arg.parse
    ["-p", Arg.Set_int port, " Listening port number (8080 by default)"]
    ignore
    "Echoes POST requests. Runs forever.";
  main !port
;;