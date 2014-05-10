exdk
====

Simple OTP application DK - data keeper, keep your data on hard disc, based on bitcask, written on Elixir lang

example of usage:

	iex(1)> ExdkGS.put("key_1", [val1: 12, val2: {1,2,true}])
	:ok

	iex(2)> ExdkGS.put("key_2", "value 2")
	:ok

	iex(3)> ExdkGS.get("key_1")
	[val1: 12, val2: {1, 2, true}]

	iex(4)> ExdkGS.get("key_2")
	"value 2"

	iex(5)> ExdkGS.getkeys     
	["key_2", "key_1"]

	iex(6)> ExdkGS.delete("key_2")
	:ok

	iex(7)> ExdkGS.getkeys        
	["key_1"]
	
	iex(8)> ExdkGS.get("key_2")   
	:not_found

