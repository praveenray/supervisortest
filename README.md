Sample code to test and demonstrate gleam's [supervisor](https://hexdocs.pm/gleam_otp/gleam/otp/supervisor.html) module.

_Running:_

1. _gleam run_
1. enter _die_ at the prompt
1. wait 10 seconds
1. enter _die_ again
    
The prompt disappears because neither driver nor worker is respawned by Supervisor!
