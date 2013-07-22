with ada.text_io, ada.integer_text_io, ada.float_text_io;
use ada.text_io, ada.integer_text_io, ada.float_text_io;
package body game_engine is
-- ascii.esc = ^[ --


procedure resetTerminal is
-- Escape sequence "^[[2J" clears the screen above the cursor --
begin
  put(ascii.esc & "[2J");
end resetTerminal;

procedure changeCoord(x,y : coordType) is 
-- Escape sequence "^[[x;yf" places cursor at (x,y) --
begin
  put(ascii.esc & "[");
  put(y,0);
  put(';');
  put(x,0);
  put("f");
end changeCoord;

procedure setForeground(color : colorType) is
begin

  case color is
    when black   =>  put(ascii.esc & "[30m");
    when red     =>  put(ascii.esc & "[31m");
    when green   =>  put(ascii.esc & "[32m");
    when yellow  =>  put(ascii.esc & "[33m");
    when blue    =>  put(ascii.esc & "[34m");
    when magenta =>  put(ascii.esc & "[35m");
    when cyan    =>  put(ascii.esc & "[36m");
    when white   =>  put(ascii.esc & "[37m");
    when boldBlack   =>  put(ascii.esc & "[1;30m");
    when boldRed     =>  put(ascii.esc & "[1;31m");
    when boldGreen   =>  put(ascii.esc & "[1;32m");
    when boldYellow  =>  put(ascii.esc & "[1;33m");
    when boldBlue    =>  put(ascii.esc & "[1;34m");
    when boldMagenta =>  put(ascii.esc & "[1;35m");
    when boldCyan    =>  put(ascii.esc & "[1;36m");
    when boldWhite   =>  put(ascii.esc & "[1;37m");
    when others      =>  Put(ascii.esc & "[35m");
  end case;

end setForeground;

procedure setBackground(color : colorType) is
begin

  case color is
    when black   =>  put(ascii.esc & "[40m");
    when red     =>  put(ascii.esc & "[41m");
    when green   =>  put(ascii.esc & "[42m");
    when yellow  =>  put(ascii.esc & "[43m");
    when blue    =>  put(ascii.esc & "[44m");
    when magenta =>  put(ascii.esc & "[45m");
    when cyan    =>  put(ascii.esc & "[46m");
    when white   =>  put(ascii.esc & "[47m");
    when boldBlack   =>  put(ascii.esc & "[1;40m");
    when boldRed     =>  put(ascii.esc & "[1;41m");
    when boldGreen   =>  put(ascii.esc & "[1;42m");
    when boldYellow  =>  put(ascii.esc & "[1;43m");
    when boldBlue    =>  put(ascii.esc & "[1;44m");
    when boldMagenta =>  put(ascii.esc & "[1;45m");
    when boldCyan    =>  put(ascii.esc & "[1;46m");
    when boldWhite   =>  put(ascii.esc & "[1;47m");
    when others      =>  Put(ascii.esc & "[0m");
  end case;

end setBackground;

end game_engine;
