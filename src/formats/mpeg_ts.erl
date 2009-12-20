%%% @author     Max Lapshin <max@maxidoors.ru>
%%% @copyright  2009 Max Lapshin
%%% @doc        MPEG TS stream module
%%% @end
%%%
%%%
%%% Copyright (c) 2009 Max Lapshin
%%%    This program is free software: you can redistribute it and/or modify
%%%    it under the terms of the GNU Affero General Public License as
%%%    published by the Free Software Foundation, either version 3 of the
%%%    License, or any later version.
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in
%%% all copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%%% THE SOFTWARE.
%%%
%%%---------------------------------------------------------------------------------------

-module(mpeg_ts).
-author('max@maxidoors.ru').
-include("../../include/ems.hrl").

-export([play/3, play/1]).



play(_Name, Player, Req) ->
  ?D({"Player starting", _Name, Player}),
  Req:stream(head, [{"Content-Type", "video/mpeg2"}, {"Connection", "close"}]),
  Req:stream(<<"MPEG TS\r\n\n\n">>),
  process_flag(trap_exit, true),
  link(Req:socket_pid()),
  Player ! start,
  play(Req),
  % ?D({"MPEG TS", Req}),
  Req:stream(close),
  ok.
  
play(Req) ->
  receive
    #video_frame{} = Frame ->
      Req:stream(<<"frame\n">>),
      ?MODULE:play(Req);
    {'EXIT', _, _} ->
      ?D({"MPEG TS reader disconnected"}),
      ok;
    Message -> 
      ?D(Message),
      ?MODULE:play(Req)
  after
    ?TIMEOUT ->
      ?D("MPEG TS player stopping"),
      ok
  end.
  
  
  
  
  
  
  
  
  
  