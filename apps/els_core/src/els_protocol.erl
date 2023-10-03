%%==============================================================================
%% The Language Server Protocol
%%==============================================================================
-module(els_protocol).

%%==============================================================================
%% Exports
%%==============================================================================
%% Messaging API
-export([
    notification/2,
    request/2,
    request/3,
    response/2,
    error/2
]).

%% Data Structures
-export([range/1]).

%%==============================================================================
%% Includes
%%==============================================================================
-include("els_core.hrl").
-include_lib("kernel/include/logger.hrl").

%%==============================================================================
%% Messaging API
%%==============================================================================
-spec notification(binary(), any()) -> iodata().
notification(Method, Params) ->
    Message = #{
        jsonrpc => ?JSONRPC_VSN,
        method => Method,
        params => Params
    },
    content(jsx:encode(Message)).

-spec request(number(), binary()) -> iodata().
request(RequestId, Method) ->
    Message = #{
        jsonrpc => ?JSONRPC_VSN,
        method => Method,
        id => RequestId
    },
    content(jsx:encode(Message)).

-spec request(number(), binary(), any()) -> iodata().
request(RequestId, Method, Params) ->
    Message = #{
        jsonrpc => ?JSONRPC_VSN,
        method => Method,
        id => RequestId,
        params => Params
    },
    content(jsx:encode(Message)).

-spec response(number(), any()) -> iodata().
response(RequestId, Result) ->
    Message = #{
        jsonrpc => ?JSONRPC_VSN,
        id => RequestId,
        result => Result
    },
    ?LOG_DEBUG("[Response] [message=~p]", [Message]),
    content(jsx:encode(Message)).

-spec error(number(), any()) -> iodata().
error(RequestId, Error) ->
    Message = #{
        jsonrpc => ?JSONRPC_VSN,
        id => RequestId,
        error => Error
    },
    ?LOG_DEBUG("[Response] [message=~p]", [Message]),
    content(jsx:encode(Message)).

%%==============================================================================
%% Data Structures
%%==============================================================================
-spec range(els_poi:poi_range()) -> range().
range(#{from := {FromL, FromC}, to := {ToL, ToC}}) ->
    #{
        start => #{line => FromL - 1, character => FromC - 1},
        'end' => #{line => ToL - 1, character => ToC - 1}
    }.

%%==============================================================================
%% Internal Functions
%%==============================================================================
-spec content(binary()) -> iodata().
content(Body) ->
    [
        <<"Content-Length: ">>,
        integer_to_binary(byte_size(Body)),
        <<"\r\n\r\n">>,
        els_utils:to_binary(Body)
    ].
