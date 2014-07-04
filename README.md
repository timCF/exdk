Exdk
====

Simple OTP application - data keeper, just keep your data on hard disc, based on ETS, written on Elixir lang

usage example:

Starting Storage...
Interactive Elixir (0.14.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Exdk.put "key1", %{a: fn() -> IO.puts("hello") end, b: 12345}
:ok
iex(2)> Exdk.put "key2", :val2
:ok
iex(3)> Exdk.get "key1"
%{a: #Function<20.106461118/0 in :erl_eval.expr/5>, b: 12345}
iex(4)> Exdk.getall
[{"key1", %{a: #Function<20.106461118/0 in :erl_eval.expr/5>, b: 12345}},
 {"key2", :val2}]
iex(5)> Exdk.delete "key2"
:ok
iex(6)> Exdk.getall
[{"key1", %{a: #Function<20.106461118/0 in :erl_eval.expr/5>, b: 12345}}]
iex(7)> Exdk.get :some
:not_found
iex(8)>
