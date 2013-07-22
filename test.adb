with ada.text_io, gnat.os_lib;
use ada.text_io, gnat.os_lib;

procedure test is

  yes : boolean;
  args : argument_list(1..0);
  
begin

  spawn(program_name => "play_snake", args => args, success =>  yes);

  if yes then
    put("IT WORKS!");
  end if;

end test;
