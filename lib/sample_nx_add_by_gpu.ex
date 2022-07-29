defmodule SampleNxAddByGpu do
  require Logger

  @moduledoc """
  A sample program that connects Nx and GPU (CUDA or Metal).
  """

  @on_load :init

  @doc false
  def init do
    case load_nif() do
      :ok ->
        case init_metal("nif_src/metal/add.metal") do
          :ok -> :ok
          {:error, char_list} -> {:error, List.to_string(char_list)}
        end

      _ ->
        :error
    end
  end

  @doc false
  def load_nif do
    nif_file = '#{Application.app_dir(:sample_nx_add_by_gpu, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc false
  def init_metal(metal_src) do
    metal_src
    |> File.read!()
    |> String.to_charlist()
    |> init_metal_nif()
  end

  @doc false
  def init_metal_nif(_metal_src), do: exit(:nif_not_loaded)

  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> SampleNxAddByGpu.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
      #Nx.Tensor<
        s32[4]
        [3, 3, 3, 3]
      >

  """
  def add_s32(x, y), do: add_s32(x, y, :gpu)

  @doc """
  Add two tensors with signed 32bit integer with specified processor.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(2, 3, :gpu)
      #Nx.Tensor<
        s32[1]
        [5]
      >

      iex> SampleNxAddByGpu.add_s32(4, 5, :cpu)
      #Nx.Tensor<
        s32[1]
        [9]
      >
  """
  def add_s32(x, y, processor), do: add(x, y, {:s, 32}, processor)

  @doc false
  def add(x, y, type, processor) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(x) do
    add(Nx.tensor([x]), y, type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(y) do
    add(x, Nx.tensor([y]), type, processor)
  end

  defp add_sub(x, y, type, processor) do
    if Nx.shape(x) == Nx.shape(y) do
      Nx.from_binary(add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type, processor), type)
    else
      raise RuntimeError, "shape is not much add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end

  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}, processor) do
    try do
      add_s32_sub(size, shape, binary1, binary2, processor)
    rescue
      e in ErlangError -> raise RuntimeError, message: List.to_string(e.original)
    end
  end

  defp add_s32_sub(size, shape, binary1, binary2, :gpu) do
    add_s32_gpu_nif(size, shape, binary1, binary2)
  end

  defp add_s32_sub(size, shape, binary1, binary2, :cpu) do
    add_s32_cpu_nif(size, shape, binary1, binary2)
  end

  @doc false
  def add_s32_gpu_nif(_size, _shape, _binary1, _binary2), do: exit(:nif_not_loaded)

  @doc false
  def add_s32_cpu_nif(_size, _shape, _binary1, _binary2), do: exit(:nif_not_loaded)
end
