defmodule SecretTest do
  use ExUnit.Case
  doctest Secret

  test "greets the world" do
    assert Secret.hello() == :world
  end
end
