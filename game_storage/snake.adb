-------------------------------------------------------------------------
-- Author:	Patrick J. Sycz	-----------------------------------------
-- Last Update:	04/20/2012	-----------------------------------------
-- Class:	Data Structures -----------------------------------------
-- Description:	"snake.adb" uses the data libraries snakeadt, leveladt --
-- and game_engine created by Patrick J. Sycz. It is a new take on the --
-- original snake game. This program displays the way you can use data --
-- structures and simple system code to create a text based game.      --
-------------------------------------------------------------------------

with ada.text_io, ada.integer_text_io, game_engine, ada.exceptions, 
     snakeADT, levelADT, gnat.os_lib;
use ada.text_io, ada.integer_text_io, game_engine, ada.exceptions,
    snakeADT, levelADT, gnat.os_lib;

procedure Snake is
  
  -- CONSTANTS --
  -- WINDOW SETUP --
  CURSOROFF : CONSTANT STRING(1..9) := "cursoroff";
  CURSORON  : CONSTANT STRING(1..8) := "cursoron"; 
  HIDETEXT  : CONSTANT STRING(1..8) := "hidetext"; 
  SHOWTEXT  : CONSTANT STRING(1..8) := "showtext"; 
  ARGS      : ARGUMENT_LIST(1..0);
 
  -- HOLD DIRECTION VALUES --
  XDIRRIGHT  : CONSTANT COORDTYPE := 2;	
  XDIRLEFT   : CONSTANT COORDTYPE := -2;	
  YDIRUP     : CONSTANT COORDTYPE := -1;	
  YDIRDOWN   : CONSTANT COORDTYPE := 1;		
  HALTDIR    : CONSTANT COORDTYPE := 0;
  -- VALUES FOR KEY MAPPINGS --
  UP         : CONSTANT CHARACTER := 'i';
  DOWN       : CONSTANT CHARACTER := 'k';
  LEFT       : CONSTANT CHARACTER := 'j';
  RIGHT      : CONSTANT CHARACTER := 'l';
  PAUSEGAME  : CONSTANT CHARACTER := 'p';
  ESC        : CONSTANT CHARACTER := ASCII.ESC;
  -- DIFFICULTY VALUES --
  EASYSPEED  : CONSTANT STANDARD.DURATION := 0.27; -- 60% < average
  MEDIUMSPEED: CONSTANT STANDARD.DURATION := 0.17; -- average
  HARDSPEED  : CONSTANT STANDARD.DURATION := 0.10; -- 60% > average
  EASY       : CONSTANT INTEGER := 1;
  MEDIUM     : CONSTANT INTEGER := 2;
  HARD       : CONSTANT INTEGER := 3;
  -- GAME STATES --
  MAXFRUIT   : CONSTANT INTEGER := 12;
  MAXLEVELS  : CONSTANT INTEGER := 10;
  LEVELUP    : CONSTANT STANDARD.DURATION := 0.77; -- 77% --
  MAPMAXX    : CONSTANT COORDTYPE := 78;
  MAPMINX    : CONSTANT COORDTYPE := 2;
  MAPMAXY    : CONSTANT COORDTYPE := 25;
  MAPMINY    : CONSTANT COORDTYPE := 1;
  APPLE      : CONSTANT CHARACTER := 'Q';
  CHERRIES   : CONSTANT CHARACTER := '8';
  CHEXMIX    : CONSTANT CHARACTER := '#';

  -- LOCALS --
  -- Hold the current direction values --
  directionX : coordType := 0;
  directionY : coordType := 0;
  -- Hold the color values --
  backColor  : colorType := black;
  wallColor  : colorType := red;
  snakeColor : colorType := green;
  snakeBack  : colorType := black;
  -- Playable/Map elements --
  snake      : snakeType;
  fruit      : fruitType;
  levelSet   : levelPtr;
  level      : levelMatrix;
  -- Game information --
  levelNum   : integer := 1;
  score      : integer := 0;
  difficulty : integer := 2;
  speed      : standard.duration := 0.15;
  keyPress   : character := '0';
  pressed    : boolean;
  exitGame   : boolean := FALSE;
  exitMap    : boolean := FALSE;
  fruitValue : integer := 0;
  fruitCount : integer := 0;
  executed   : boolean;
begin

  resetTerminal;
  -- Load the levels, load a fruit, initialize snake --
  load(levelSet);
  -- turn off cursor and input text off by --
  -- executing scripts outside of program  --
  spawn(HIDETEXT, ARGS, executed);
  spawn(CURSOROFF, ARGS, executed); 
  -- Begin main game loop --
  while not exitGame loop

    levelNum := 1;
    level := getLevel(levelSet, levelNum);
    initialize(snake);
    setFruit(fruit, snake, level);
    
    -- reset terminal, display title actions, set up game --
    resetTerminal;
    displayTitle(keyPress, difficulty, backColor, wallColor, snakeColor, snakeBack);
    case difficulty is
      when 1 => speed := EASYSPEED;
      when 2 => speed := MEDIUMSPEED;
      when 3 => speed := HARDSPEED;
      when others => speed := MEDIUMSPEED;
    end case;

    -- Check for quit game --
    if keyPress = ESC then
      exitGame := TRUE;
      exitMap  := TRUE;
    else     
      -- initialize directions, hold stage for key press --
      directionY := HALTDIR;
      directionX := XDIRRIGHT;
      displayLevel(level, black, white);
      displaySnake(snake, black, white);
      pause(keyPress);
      exitMap := FALSE;
      changeCoord((MAPMAXX - 10), (MAPMAXY + 1));
      setBackground(black);
      setForeground(cyan);
      put("Level: ");
      put(levelNum, 2);
      changeCoord(1,1);
      fruitCount := 0;
    end if;
    while not exitMap loop
      -- set speed of the game, check for input --
      delay speed;
      begin -- make sure data is okay --
        get_immediate(keyPress, pressed);
      exception
	when data_error | constraint_error =>
	  put("CONSTRAINT ERROR");
	  delay 3.0;
	  get_immediate(keyPress);
	  get_immediate(keyPress);
	  get_immediate(keyPress);
	  put("ERROR: INVALID INPUT");
	  keypress := '0'; -- reset the keypress --
      end; -- end validation --
      -- Check the amount of fruit eaten, advance levels -- 
      if fruitCount >= MAXFRUIT then -- / MAXFRUIT = 1 then
	delay 1.0; -- let user register last fruit was eaten --
	-- initialize snake, fruit, advance level --
	initialize(snake);
	fruitCount := 0;
	levelNum := levelNum + 1;
	if levelNum > MAXLEVELS then 
	  levelNum := 1;
	  speed := (speed * LEVELUP); -- decrease speed 23% --
  	  changeCoord((MAPMAXX / 2) - 5, (MAPMAXY / 2) + 1);
	  setForeground(black);
	  setBackground(white);
	  put("LEVEL UP");
          delay 1.0;
         end if;
	-- change level numbers --
	changeCoord((MAPMAXX - 10), (MAPMAXY + 1));
	setBackground(black);
	setForeground(cyan);
	put("Level: ");
	put(levelNum, 2);
	level := getLevel(levelSet, levelNum);
	displayLevel(level, black, white);
	displaySnake(snake, black, white);
	-- pause screen and tell user they leveled up --
	changeCoord((MAPMAXX / 2) - 7, (MAPMAXY / 2) + 1);
	setForeground(red);
	setBackground(black);
	put("PRESS ANY KEY");
        setFruit(fruit, snake, level);
	-- wait for a keypress, reset velocities --
	pause(keyPress);
	directionY := HALTDIR;
	directionX := XDIRRIGHT;
	keyPress := RIGHT;
      end if;

      -- check for a pause game --
      if keyPress = PAUSEGAME then
	pause(keyPress);
      end if;

      -- Check for key presses, adjust the directions --
      if keyPress = UP and then directionY /= YDIRDOWN then
	directionY := YDIRUP;
	directionX := HALTDIR;

      elsif keyPress = DOWN and then directionY /= YDIRUP then
	directionY := YDIRDOWN;
	directionX := HALTDIR;

      elsif keyPress = LEFT and then directionX /= XDIRRIGHT then
	directionX := XDIRLEFT;
	directionY := HALTDIR;

      elsif keyPress = RIGHT and then directionX /= XDIRLEFT then
	directionX := XDIRRIGHT;
	directionY := HALTDIR;

      elsif keypress = ESC then
	exitMap := TRUE;
      end if;

      -- Make sure the snake doesn't leave the map, adjust accordingly --
      if snake.x >= MAPMAXX and then directionX = XDIRRIGHT then
	snake.x := MAPMINX;
      elsif snake.x <= MAPMINX and then directionX = XDIRLEFT then
	snake.x := MAPMAXX;
      elsif snake.y >= MAPMAXY and then directionY = YDIRDOWN then
	snake.y := MAPMINY;
      elsif snake.y <= MAPMINY and then directionY = YDIRUP then
	snake.y := MAPMAXY;
      end if;

      -- Display the level, snake, and fruit --
      displayLevel(level, wallColor, backColor);
      moveSnake(snake, directionX, directionY);
      dropFruit(fruit, backColor);
      displaySnake(snake, snakeColor, snakeBack);
      changeCoord(1,1); -- reset to upper left corner --

      -- test for game ending collisions --
      if not exitMap then
	exitMap :=  testSelfCollide(snake);
	if not exitMap then
	  exitMap := testWallCollide(snake, level);
        end if;
      end if;

      -- check for fruit collisions --
      fruitValue := testFruitCollide(snake, fruit);
      if fruitValue > 0 then
	-- add one to the fruits eaten --
	fruitCount := fruitCount + 1;
	-- make difficulty adjustments --
        if difficulty = EASY then
	  fruitValue := (fruitValue * 3) / 5; -- 60% less than average
	elsif difficulty = HARD then
	  fruitValue := (fruitValue * 8) / 5; -- 60% more than average
	end if;
	-- increase scores --
	score := score + fruitValue;
	if fruit.symbol = APPLE then
	  growSnake(snake, 4);
	elsif fruit.symbol = CHERRIES then
	  growSnake(snake, 8);
	elsif fruit.symbol = CHEXMIX then
	  growSnake(snake, 12);
        else
	  growSnake(snake, 18); 
	end if;
        setFruit(fruit, snake, level);
      end if;

      -- Display score in lower left hand corner --
      setBackground(black);
      setForeground(cyan);
      changeCoord(MAPMINX - 1, MAPMAXY + 1);
      put(" Score: ");
      put(score, 0);
      changeCoord((MAPMAXX /2) - 6, MAPMAXY + 1);
      put("Fruit to go: ");
      setForeground(yellow);
      put((MAXFRUIT - fruitCount), 2);
      changeCoord(1,1);

      if exitMap then
	delay 2.0;
      end if;
    end loop; -- sub game loop --

    displayHighScores(score);
    score := 0;
  end loop; -- main game loop --
  put(ascii.esc & "[0m");
  -- turn cursor and keyboard text back on --
  spawn(SHOWTEXT, ARGS, executed);
  spawn(CURSORON, ARGS, executed);
  resetTerminal;
end Snake;	
