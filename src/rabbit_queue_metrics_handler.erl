-module(rabbit_queue_metrics_handler).

-export([init/2]).

init(Req0, _Opts) ->
    #{name := QName} = cowboy_req:match_qs([{name, [], undefined}], Req0),
    #{regex := QRegex} = cowboy_req:match_qs([{regex, [], undefined}], Req0),
    QueuesByName = rabbit_queue_metrics_worker:list_queues_by_name(QName),
    QueuesByRegex = rabbit_queue_metrics_worker:list_queues_by_regex(QRegex),
    QueuesJSON = jsx:encode(QueuesByName ++ QueuesByRegex),
    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, QueuesJSON, Req0),
    {ok, Req, no_state}.