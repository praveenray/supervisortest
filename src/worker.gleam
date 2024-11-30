import gleam/string
import gleam/erlang.{type Reference}
import gleam/function
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/io

pub const my_name = "worker"

pub type State {
    State()
}
pub fn start_actor(ets_table: Reference) {
  let spec = actor.Spec(
    init: fn() {
      init(ets_table)
    },
    loop: loop,
    init_timeout: 1000
  )
  actor.start_spec(spec)
}

fn init(ets_table: Reference) -> actor.InitResult(State, #(Subject(String), String)) {
  io.println("worker init: " <> string.inspect(process.self()))
  let myself = process.new_subject()
  let assert Ok(Nil) = add_subject(ets_table, my_name, myself)
  let selector = process.new_selector() |> process.selecting(myself, function.identity)
  actor.Ready(State, selector)
}

fn loop(msg: #(Subject(String), String), state: State) -> actor.Next(#(Subject(String), String), State) {
  case msg {
    #(sender, request)  -> {
      case request {
        "die" -> {
          let assert True = False
          io.println("not reached")
        }
        _ -> {
          let reply = "Continuing with Worker " <> string.inspect(process.self()) <> " " <> request
          process.send(sender, reply)
          io.println(reply)
        }
      }
    }
  }

  actor.continue(state)
}

@external(erlang, "erlang_functions", "add_subject")
pub fn add_subject(ets_table: Reference, name: String, subject: Subject(a)) -> Result(Nil, String)
