import gleam/erlang/process.{type Subject}
import gleam/erlang.{type Reference}
import gleam/otp/supervisor as sup
import worker
import driver

pub const ets_table = "global_table"

pub fn main() {
  let assert Ok(ets_table) = create_ets_table(ets_table)
  let myself = process.new_subject()
  let child = sup.worker(fn(_) {
    worker.start_actor(ets_table)
  })
  let driver_child = sup.worker(fn(_) {
    driver.start_actor(ets_table, myself)
  })

  let assert Ok(_) = supervise(child, driver_child)
  process.sleep_forever()
}

fn supervise(
  worker: sup.ChildSpec(#(Subject(String), String), Nil, Nil),
  driver_child: sup.ChildSpec(String, Nil, Nil)
) {
  sup.start(fn(children) {
      children
      |> sup.add(worker)
      |> sup.add(driver_child)
  })
}

@external(erlang, "erlang_functions", "create_ets_table")
pub fn create_ets_table(table_name: String) -> Result(Reference, String)
