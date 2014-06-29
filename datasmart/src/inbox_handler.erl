%%%-------------------------------------------------------------------
%%% @author evangelosp
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(inbox_handler).
-author("evangelosp").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  {Method, _} = cowboy_req:method(Req),
  {ok, Req3} = maybe_response(Method, Req),
  {ok, Req3, State}.

maybe_response(<<"GET">>, Req) ->
  {Messageid, Req2} = cowboy_req:qs_val(<<"messageid">>, Req),
  {OUkey, Req3} = cowboy_req:qs_val(<<"user">>, Req2),
  case {OUkey, Messageid} of
    {undefined, undefined} -> echo(400, jiffy:encode({[
      {code, 400},
      {status, error},
      {error, "Missing Parameters."}
    ]}), Req);
    {_, _} ->
      case handle_query(OUkey, Messageid, Req3) of
        {list, MList, _} ->
          echo(200, jiffy:encode({[
            {status, ok},
            {list, MList}
          ]}), Req);
        {message, Subject, Message, _} ->
          echo(400, jiffy:encode({[
            {messageId, Messageid},
            {subject, Subject},
            {message, Message},
            {from_day, os:timestamp()},
            {to_day, os:timestamp()}
          ]}), Req);
        _ ->
          echo(400, jiffy:encode({[
            {code, 400},
            {status, error},
            {error, "Uknown Error"}
          ]}), Req)
      end
  end;

maybe_response(_, Req) ->
  echo(405, jiffy:encode({[
    {code, 405},
    {status, error},
    {error, "Method not allowed."}
  ]}), Req).

handle_query(OUkey, undefined, Req) ->
  {ok, Ukey} = user_server:match_ouKey(OUkey),
%%   TODO Fetch List of Inbox Messages
  {ok, ensureInboxItemJson([]), Req};

handle_query(OUkey, Messageid, Req) ->
  {ok, Ukey} = user_server:match_ouKey(OUkey),
%%   TODO Fetch Message info
  {ok, ensureMessageJson([{messageid, Messageid}]), Req};

handle_query(_, _, Req) ->
  {error, "Bad body Request", Req}.

echo(Status, Echo, Req) ->
  cowboy_req:reply(Status, [
    {<<"content-type">>, <<"application/json; charset=utf-8">>},
    {<<"server">>, <<"myinbox-datastore">>}
  ], Echo, Req).

terminate(_Reason, _Req, _State) ->
  ok.

ensureMessageJson(Json) ->
  [
    {messageid, proplists:get_value(messageid, Json)},
    {from, proplists:get_value(<<"from">>, Json)},
    {to, proplists:get_value(<<"to">>, Json)},
%%     {ukey, proplists:get_value(<<"ukey">>, Json)},
    {date, proplists:get_value(<<"date">>, Json)},
    {subject, proplists:get_value(<<"subject">>, Json)},
    {body, proplists:get_value(<<"body">>, Json)},
    {meta, proplists:get_value(<<"meta">>, Json, [])}
  ].

ensureInboxItemJson(Json) ->
  [
    {messageid, proplists:get_value(messageid, Json)},
    {from, proplists:get_value(<<"from">>, Json)},
    {date, proplists:get_value(<<"date">>, Json)},
    {subject, proplists:get_value(<<"subject">>, Json)}
  ].