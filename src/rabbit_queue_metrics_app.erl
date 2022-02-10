-module(rabbit_queue_metrics_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  erlang:display(application:info()),
  start_http_server(),
	rabbit_queue_metrics_sup:start_link().

stop(_State) ->
	ok.

start_http_server() ->
    Dispatch = cowboy_router:compile([{'_', [{"/queues", rabbit_queue_metrics_handler, []}]}]),
    {ok, _} = cowboy:start_clear(http, [{port, 8000}, {ip, {127,0,0,1}}], #{env => #{dispatch => Dispatch}}).
