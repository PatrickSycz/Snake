with ada.text_io, ada.integer_text_io, ada.float_text_io, game_engine, snakeADT, levelADT, ada.exceptions, gnat.os_lib;
use ada.text_io, ada.integer_text_io, ada.float_text_io, game_engine, snakeADT, levelADT, ada.exceptions, gnat.os_lib;

procedure test_engine is

  args  : argument_list(1..0);
  hidetext: string(1..8) := "hidetext";
  showtext: string(1..8) := "showtext";
  cursoron: string(1..8) := "cursoron";
  cursoroff:string(1..9) := "cursoroff";
  passed  : boolean;
  foreground : colorType := green;
  background : colorType := black;
  coordx     : coordType := 1;
  coordy     : coordType := 1;
  xerase     : coordType := 2;
  yerase     : coordType := 2;
  snake : snakeType;
  key   : character;
  key2  : character;
  go    : boolean;
  count : integer := 1;
  exitFlag : boolean;
  levels   : levelPtr;
  levelNum : integer := 1;
  score : integer := 10;
  layout : levelMatrix;
  fruit : fruitType;
  speed : standard.Duration := 0.16;
  mode : integer;
  BC, WC, SC, SB : colorType;
begin
  BC := black;
  WC := red;
  SC := green;
  SB := black;
  load(levels);
  fruit.symbol := '#';
  fruit.x := 22; 
  fruit.y := 16;
  score := 0;
  resetTerminal;
  --delay 6.0;
  layout := getLevel(levels, levelNum);
loop
  spawn(hidetext, args, passed);
  spawn(cursoroff, args, passed);
  resetTerminal;
  displayTitle(key, mode, BC, WC, SC, SB);
  if key = ascii.esc then
    exit;
  end if;
  initialize(snake);
  initialize(snake);
  resetTerminal;
  coordx :=2;
  coordy :=0;
  layout := getLevel(levels, levelNum);
  displayLevel(layout, yellow, black);
  displaySnake(snake, red, black);
  exitFlag := false;
  setBackground(black);
    count := 5;
    levelNum := 6;
    while not exitFlag loop

    delay speed;
    begin
      get_immediate(key,go);
    exception
      when constraint_error =>
	get_immediate(key);
	get_immediate(key);
	get_immediate(key);
	if key = 'A' then
	  key := 'i';
	elsif key = 'B' then
	  key := 'k';
	elsif key = 'C' then
	  key := 'j';
	elsif key = 'D' then
	  key := 'l';
        end if;
    end;
  
    if count / 5 = 1 then
      initialize(snake);
      count := 1;
      levelNum := levelNum + 1;
      if levelNum > 10 then
        levelNum := 6;
        speed := speed - 0.02;
      end if;
      layout := getLevel(levels, levelNum);
      displayLevel(layout, red, black);
      displaySnake(snake, yellow, magenta);
      setFruit(fruit, snake,layout);
      get_immediate(key);
      key := 'l';
      coordx := 2;
    end if;

    if key = 'i' and then coordy /= 1 then
      coordy := -1;
      coordx := 0;

    elsif key = 'k' and then coordy /= -1 then
      coordy := 1;
      coordx := 0;

    elsif key = 'j' and then coordx /= 2 then
      coordx := -2;
      coordy := 0;

    elsif key = 'l' and then coordx /= -2 then
      coordx := 2;
      coordy := 0;

    elsif key = 'p' then
      pause(key);

    elsif key = ascii.esc then
      exitFlag := TRUE;
      delay 1.0;
    end if;
    if snake.x >= 78 and coordx = 2 then 
      snake.x := 2;
    elsif snake.x <= 2 and coordx = -2 then
      snake.x := 78;
    elsif snake.y >= 25 and coordy = 1 then
      snake.y := 1;
    elsif snake.y <= 1 and coordy = -1 then
      snake.y := 25;
    end if;
    
    displayLevel(layout, WC, BC);
    dropfruit(fruit, BC);
    
    moveSnake(snake, coordx, coordy); 
    displaySnake(snake, SC, SB);--, green, black);
    changeCoord(1,1);

--    if not exitFlag then
--      exitFlag := testSelfCollide(snake);
--    end if;
--    if not exitFlag then
--      exitFlag := testWallCollide(snake, layout);
--    end if;
    
    if testFruitCollide(snake, fruit) > 0 then
      score := score + testFruitCollide(snake, fruit);
      count := count + 1;
      growSnake(snake, 200);
      setFruit(fruit, snake,layout);
    end if;
    setBackground(black);
    setForeground(cyan);
    changeCoord(1, 26);
    put("Score: ");
    put(score, 0);
    changeCoord(1,1);
    if exitFlag then
      delay 1.0;
    end if;
 end loop;
  displayHighScores(score);
end loop;
  spawn(showtext, args, passed);
  spawn(cursoron, args, passed);
  put(ascii.esc & "[0m");
  changeCoord(1,1);
  resetTerminal;
end test_engine;
