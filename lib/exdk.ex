defmodule Exdk do
  use Application

  @table :program_storage

  # See http://elixir-lang.org/docs/stable/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    :ets.new(@table, [:public, :named_table, {:write_concurrency, true}, {:read_concurrency, true}, :protected])

    children = [
                  worker(Exdk.Server,[])
      # Define workers and child supervisors to be supervised
      # worker(Exdk.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exdk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def put(etskey, newdata) do
    true = :ets.insert @table, {etskey, newdata}
    :ok
  end
  def delete(etskey) do
    true = :ets.delete @table, etskey
    :ok
  end
  def get(etskey) do
    case :ets.lookup @table, etskey do
      [{ _ , data}] -> data
      []        -> :not_found
    end
  end
  def getall do
    :ets.tab2list( @table )
  end


end


defmodule Exdk.Server do

  @timeout :timer.seconds(10)
  @table :program_storage

  use ExActor.GenServer

  definit do
    IO.puts "Starting Storage..."

    File.mkdir("./program_data")
    File.touch("./program_data/new")
    File.touch("./program_data/old")
    File.touch("./program_data/mark_new")
    File.touch("./program_data/mark_old")

    case File.read("./program_data/mark_new") do
      {:ok, "done"} -> use_new()
      _             -> use_old()
    end
    {:ok, nil, @timeout}
  end
  defp use_new do
    case File.read("./program_data/new") do
      {:ok, ""}      -> use_old()
      {:ok, bindata} -> old_recovery()
                        ets_recovery(:erlang.binary_to_term(bindata))
      _              -> use_old()
    end
  end
  defp use_old do
    case File.read("./program_data/old") do
      {:ok, ""}      -> :ok
      {:ok, bindata} -> new_recovery()
                        ets_recovery(:erlang.binary_to_term(bindata))
      _              -> :ok
    end
  end
  defp ets_recovery(lst) do
    Enum.each( lst, fn(x) -> true = :ets.insert(@table, x) end )
  end
  defp old_recovery do
    case File.read("./program_data/mark_old") do
      {:ok, "done"} ->  :ok
      _             ->  :ok = write("./program_data/old", File.read!("./program_data/new"))
                        :ok = write("./program_data/mark_old", "done")
    end
  end
  defp new_recovery do
    case File.read("./program_data/mark_new") do
      {:ok, "done"} ->  :ok
      _             ->  :ok = write("./program_data/new", File.read!("./program_data/old"))
                        :ok = write("./program_data/mark_new", "done")
    end
  end
  definfo :timeout do
    bindata = :erlang.term_to_binary(:ets.tab2list( @table ))

    :ok = write("./program_data/mark_new", "")
    reserve = File.read!("./program_data/new")
    :ok = write("./program_data/new", bindata)
    :ok = write("./program_data/mark_new","done") # success, write mark

    :ok = write("./program_data/mark_old", "")
    :ok = write("./program_data/old", reserve) # reserve copy of old state
    :ok = write("./program_data/mark_old","done") # success, write mark

    {:noreply, nil, @timeout}
  end

  defp write(file, data) do
    case :file.open(file, [:write]) do
      {:ok, io} -> 
        case :file.write(io, data) do
          :ok ->
            case :file.sync(io) do
              :ok ->
                case :file.close(io) do
                  :ok -> :ok
                  _err -> {:close, _err}
                end
              _err -> 
                spawn fn -> :file.close(io) end
                {:sync, _err}
            end
          _err -> 
            spawn fn -> :file.close(io) end
            {:write, _err}
        end
      _err -> {:open, _err}
    end
  end

end