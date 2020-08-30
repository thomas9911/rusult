defmodule Rusult.Behaviour do
    @callback ok() :: struct
    @callback ok(any) :: struct
    @callback error(any) :: struct
    @callback from(any) :: struct
    @callback to_tuple(any) :: tuple
    @callback to_tuple(any, keyword) :: tuple
end