defmodule Exdk do
  use Application

  # See http://elixir-lang.org/docs/stable/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Exdk.Supervisor.start_link
  end
end

defmodule ExdkGS do
	use ExActor.GenServer, export: :ExdkGS

	definit do
		# load/create Bitcask datastore
		{:ok, :bitcask.open('./program_data', 	[	:read_write,
													:sync_on_put
												])} 
	end

	# key - term
	defcall get(key), state: datahandler do
		case :bitcask.get(datahandler, :erlang.term_to_binary(key)) do
			{:ok, data} -> {:reply, :erlang.binary_to_term(data), datahandler}
			:not_found	-> {:reply, :not_found, datahandler}
		end
	end


	defcall getkeys(), state: datahandler do
		{	:reply, 
			:bitcask.list_keys(datahandler) |> Enum.map(&(:erlang.binary_to_term(&1))),
			datahandler
		}
	end

	# key, value - terms
  	defcast put( key, value ), state: datahandler do 
  		:ok = :bitcask.put(datahandler, :erlang.term_to_binary(key), :erlang.term_to_binary(value))
  		{:noreply, datahandler}
  	end


  	# key - term
  	defcast delete( key ), state: datahandler do
  		:ok = :bitcask.delete(datahandler, :erlang.term_to_binary(key))
  		{:noreply, datahandler}
  	end



  	def terminate _reason, datahandler do
  		:ok = :bitcask.close datahandler
  	end

end