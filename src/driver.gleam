import gleam/function
import gleam/string
import gleam/otp/actor.{type StartError}
import gleam/io
import gleam/erlang/process.{type Subject}
import gleam/erlang.{type Reference}
import worker

pub const my_name = "driver"

pub type State {
    State(ets_table: Reference)
}

pub fn start_actor(ets_table: Reference) -> Result(Subject(String), StartError) {
  let spec = actor.Spec(
    init: fn() {
      init(ets_table)
    },
    loop: loop,
    init_timeout: 10_000
  )
  actor.start_spec(spec)
}

fn init(ets_table: Reference) -> actor.InitResult(State, String) {
  let self = string.inspect(process.self())
  io.println("driver init: " <> self)
  let myself = process.new_subject()
  let selector = process.new_selector() |> process.selecting(myself, function.identity)
  let assert Ok(Nil) = add_subject(ets_table, my_name, myself)

  process.send(myself, "continue")
  actor.Ready(State(ets_table), selector)
}

fn loop(_msg: String, state: State) -> actor.Next(String, State) {
  let assert Ok(line) = erlang.get_line("enter a command: ")
  let assert Ok(myself) = get_subject(state.ets_table, my_name)
  let assert Ok(worker) = get_subject(state.ets_table, worker.my_name)
  process.call(worker, fn(sender) {
    #(sender, string.trim(line))
  }, 10_000)

  process.send(myself, "continue")
  actor.continue(state)
}

@external(erlang, "erlang_functions", "add_subject")
pub fn add_subject(ets_table: Reference, name: String, subject: Subject(a)) -> Result(Nil, String)

@external(erlang, "erlang_functions", "get_subject")
pub fn get_subject(ets_table: Reference, name: String) -> Result(Subject(a), String)
