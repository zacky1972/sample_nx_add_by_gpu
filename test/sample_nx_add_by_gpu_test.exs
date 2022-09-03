defmodule SampleNxAddByGpuTest do
  use ExUnit.Case
  doctest SampleNxAddByGpu

  test "uint32_t overflow" do
    t = Nx.tensor([2 ** 31 - 1], type: {:s, 32})
    assert Nx.add(t, 1) == SampleNxAddByGpu.add_s32(t, 1, :cpu)
    assert Nx.add(t, 1) == SampleNxAddByGpu.add_s32(t, 1, :gpu)
  end
end
