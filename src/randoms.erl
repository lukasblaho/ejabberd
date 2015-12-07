%%%----------------------------------------------------------------------
%%% File    : randoms.erl
%%% Author  : Alexey Shchepin <alexey@process-one.net>
%%% Purpose : Random generation number wrapper
%%% Created : 13 Dec 2002 by Alexey Shchepin <alexey@process-one.net>
%%%
%%%
%%% ejabberd, Copyright (C) 2002-2015   ProcessOne
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License along
%%% with this program; if not, write to the Free Software Foundation, Inc.,
%%% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%%%
%%%----------------------------------------------------------------------

-module(randoms).

-author('alexey@process-one.net').

-export([get_string/0]).

-export([start/0, init/0]).

start() ->
    lists:foreach(
      fun(I) ->
	      register(get_proc(I), spawn(randoms, init, []))
      end, lists:seq(1, pool_size())).

init() ->
    random:seed(p1_time_compat:timestamp()), loop().

loop() ->
    receive
      {From, get_random, N} ->
	  From ! {random, random:uniform(N)}, loop();
      _ -> loop()
    end.

get_string() ->
    {_, _, USec} = p1_time_compat:timestamp(),
    Proc = get_proc((USec rem pool_size()) + 1),
    Proc ! {self(), get_random, 65536 * 65536},
    receive
      {random, R} -> jlib:integer_to_binary(R)
    end.

pool_size() ->
    10.

get_proc(I) ->
    list_to_atom("random_generator_" ++ integer_to_list(I)).
