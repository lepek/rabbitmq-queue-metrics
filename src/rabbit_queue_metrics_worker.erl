-module(rabbit_queue_metrics_worker).

-include_lib("rabbit_common/include/rabbit.hrl").

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-export([list_queues_by_name/1, list_queues_by_regex/1]).

-behaviour(gen_server).

-define(VHOST, <<"/">>).

%% API

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

list_queues_by_name(QName) ->
    gen_server:call(?MODULE, {list_queues_by_name, QName}, infinity).

list_queues_by_regex(QRegex) ->
    gen_server:call(?MODULE, {list_queues_by_regex, QRegex}, infinity).

%% Callbacks

init([]) ->
    {ok, #{}}.

handle_call({_, undefined}, _From, State) ->
    {reply, [], State};

handle_call({list_queues_by_regex, QRegex}, _From, State) ->
    {ok, MP} = re:compile(QRegex),
    FilteredQueues = [Q || Q <- rabbit_amqqueue:list(?VHOST), match(Q, MP)],
    Res = [get_info(amqqueue:get_name(Q)) || Q <- FilteredQueues],
    {reply, Res, State};

handle_call({list_queues_by_name, QName}, _From, State) ->
%%    io:fwrite("~p~n", [QName]),
    FullQueueName = rabbit_misc:r(?VHOST,queue,QName),
    {reply, [get_info(FullQueueName)], State};

handle_call(_Msg, _From, State) ->
    {reply, not_implemented, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

%% Helpers

get_info(QName) ->
    case rabbit_amqqueue:lookup(QName) of
      {ok, Q} ->
          QInfo = rabbit_amqqueue:info(Q),
          {_, _, _, Name} = proplists:get_value(name, QInfo),
          #{
              name => Name,
              messages => proplists:get_value(messages, QInfo),
              messages_ready => proplists:get_value(messages_ready, QInfo),
              messages_unacknowledged => proplists:get_value(messages_unacknowledged, QInfo),
              memory => proplists:get_value(memory, QInfo),
              consumers => proplists:get_value(consumers, QInfo),
              head_message_timestamp => proplists:get_value(head_message_timestamp, QInfo)
          };
      _ ->
          #{}
    end.

match(Q, MP) ->
    {_, _, _, Name} = amqqueue:get_name(Q),
    is_match(re:run(Name, MP)).

is_match({match, _Captured}) ->
    true;
is_match(nomatch) ->
    false.
