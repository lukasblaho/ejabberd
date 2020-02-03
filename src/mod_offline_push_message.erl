-module(mod_offline_push_message).

-behaviour(gen_mod).

-include("xmpp.hrl").

%% Required by ?INFO_MSG macros
-include("logger.hrl").

%% gen_mod API callbacks
-export([start/2, stop/1, depends/2, mod_options/1, create_push_message/1]).

start(_Host, _Opts) ->
    ?INFO_MSG("Hello, ejabberd world!", []),
    ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_push_message, 50),
    ok.

stop(_Host) ->
    ?INFO_MSG("Bye bye, ejabberd world!", []),
    ok.

depends(_Host, _Opts) ->
    [].

mod_options(_Host) ->
    [].

create_push_message({_Action, #message{type = Type, from = From, to = To, body = Body} = _Packet} = Acc) ->
?INFO_MSG("create push message", []),
if 
Type == chat ->
    post_push_message(From, To, Body),
    Acc;
true -> Acc    
end.    

post_push_message(Sender, Receiver, Body) ->
httpc:request(post, {"https://api-dev.roadlords.net/api/chat/notify",[{"Api-Key","sgdgfVxddfTR63TRdsFd23DFD2S5aJ7b9C2D6fRdsGgUghSXDcF"}, {"Accept-Version","2"}], "application/json", jiffy:encode(#{'From' => jid:encode(Sender), 'To' => jid:encode(Receiver), 'Body' => xmpp:get_text(Body)})}, [], []),
?INFO_MSG("Push sent!", []).