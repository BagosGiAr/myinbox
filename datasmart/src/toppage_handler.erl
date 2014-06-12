%%%-------------------------------------------------------------------
%%% @author evangelosp
%%% @copyright (C) 2014, evalonlabs
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(toppage_handler).
-author("evangelosp").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  HasBody = cowboy_req:has_body(Req2),
  {ok, Req3} = maybe_echo(Method, HasBody, Req2),
  {ok, Req3, State}.

maybe_echo(<<"POST">>, true, Req) ->
  {ok, PostVals, Req2} = cowboy_req:body_qs(Req),
  case {
    proplists:is_defined(<<"echo">>, PostVals),
    proplists:is_defined(<<"echo">>, PostVals)
  }
  of
    {true, true} ->
      Echo = proplists:get_value(<<"echo">>, PostVals),
      echo(Echo, Req2);
    _ -> cowboy_req:reply(400, [], <<"Bad body.">>, Req)
  end;
maybe_echo(<<"POST">>, false, Req) ->
  cowboy_req:reply(400, [], <<"Missing body.">>, Req);
maybe_echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

echo(Echo, Req) ->
  cowboy_req:reply(200, [
    {<<"content-type">>, <<"text/plain; charset=utf-8">>}
  ], << Echo/binary, "\r\n\r\n" >>, Req).

terminate(_Reason, _Req, _State) ->
  ok.