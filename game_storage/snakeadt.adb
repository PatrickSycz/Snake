------------------------------------------------------------
-- Name: Patrick Sycz 	------------------------------------
-- Package Description: Body of snakeADT implements all   --
-- availabe functions/subprograms declared in the spec	  --
------------------------------------------------------------
--
with ada.text_io, ada.integer_text_io, game_engine, leveladt,
 ada.numerics.discrete_random, ada.unchecked_deallocation;
use ada.text_io, ada.integer_text_io, game_engine, leveladt;

package body snakeADT is

  -- Global List Head and Tail --
  first : snakeType;
  last  : snakeType;
  -- Starting positions for snake --
  xStart: constant coordType := 8;
  yStart: constant coordType := 22;

  -- garbage collection --
  procedure free is new ada.unchecked_deallocation(object => snakeNode,
						   name => snakeType);
  -- random coordinate library --
  package Random_Coordinates is new Ada.Numerics.Discrete_Random(CoordType);
  use Random_Coordinates;

-------------------------------------------------------------------------------
-- initialize the snake to length 8 --
  procedure initialize(snake : in out snakeType) is
    tmp : snakeType := snake;
  begin
    -- clear out previous snake if needed --
    while snake /= NULL loop
      tmp := snake;
      if tmp.next /= NULL then
        snake := tmp.next;
        tmp.next.prev := snake;
        free(tmp);
      else
	snake := tmp.next;
        last := NULL;
	first := NULL;
	free(tmp);
      end if;

    end loop;
    snake := new snakeNode'( '@', xStart, yStart, last, first); 
    last  := snake;
    for i in 1..4 loop
      -- insert 4 more nodes to start --
      snake := new snakeNode'( '@', snake.x +  2, yStart, snake, first);
      snake.next.prev := snake;
    end loop;
    first := snake;
  end initialize;

-------------------------------------------------------------------------------

  procedure displaySnake(snake : snakeType; fore: colorType := green;
			 back: colorType := black) is
    tmp : snakeType := snake;
  begin
    setForeground(fore);
    setBackground(back);
    while tmp /= NULL loop
      changeCoord(tmp.x, tmp.y);
      put(tmp.symbol);
      tmp := tmp.next;
    end loop;
  end displaySnake;

-------------------------------------------------------------------------------

  procedure moveSnake(snake : in out snaketype; xChange, yChange : coordType) is
    tmp : snakeType; -- tmp used to shift coordinates --
  begin
    -- move to the bottom end of the snake and change coordinates to next ones
    tmp := last;
    while tmp.prev /= NULL loop
      tmp.x := tmp.prev.x;
      tmp.y := tmp.prev.y;
      tmp := tmp.prev;
    end loop;
    -- change the snake's head x,y coordinates --
    snake.x := snake.x + xChange;
    snake.y := snake.y + yChange;
  end moveSnake;
    
-------------------------------------------------------------------------------

  procedure growSnake(snake : in out snakeType; amount : integer) is 
  -- grows snake "amount" spaces --
  begin
    -- create 1-amount nodes at the end --
    for i in 1..amount loop
      last := new snakeNode'( '@', last.x, last.y, last.next, last);
      last.prev.next := last;
    end loop;
  end growSnake;

-------------------------------------------------------------------------------

  function testSelfCollide(snake : snakeType) return boolean is
  -- check if the snake collides with itself --
    -- tmp is the next position of the snake, collided is true or false --
    tmp : snakeType := snake;
    collided : boolean := FALSE;
  begin
    -- it is impossible to collide into the first four spots --
    for i in 1..4 loop
      if tmp.next /= NULL then
	tmp := tmp.next;
      end if;
    end loop;
    -- loop while there's still pieces to check and you haven't found collision
    while tmp /= NULL and then NOT collided loop
      if snake.x = tmp.x and then snake.y = tmp.y then
        collided := TRUE;
      else
        tmp := tmp.next;
      end if;
    end loop;
    return collided;
  end testSelfCollide;

-------------------------------------------------------------------------------

  function testWallCollide(snake : snakeType; layout : levelmatrix) return
  boolean is
  -- tests for collision with the wall --
    -- collided is true or false --
    collided : boolean := FALSE;
  begin
    -- if snake is not empty check it's coordinates with the wall's --
    if snake /= NULL then
      if layout(snake.x, snake.y) /= ' ' then
        collided := TRUE;
      end if;
    end if;
    return collided;
  end testWallCollide;

-------------------------------------------------------------------------------
 
  function xWallDrop(fruit : fruitType; level : levelMatrix) return CoordType is
  -- old function ** moved x coordinate if wall was in the way --
    x : coordType := fruit.x;
  begin
    while level(x, fruit.y) /= ' ' and then x < 66 loop
      x := x + 2;
    end loop;
    return x;
  end xWallDrop;

-------------------------------------------------------------------------------

  function yWallDrop(fruit : fruitType; level : levelMatrix) return CoordType is
  -- old function ** moved y coordinate if wall was in the way --
    y : coordType := fruit.y;
  begin
    while level(fruit.x, y) /= ' ' and then y > 3 loop
      y := y - 1;
    end loop;
    return y;
  end yWallDrop;

-------------------------------------------------------------------------------

  procedure snakeWallDrop(fruit:in out fruitType; snake: snakeType; 
		          level:levelMatrix) is
  -- check for a drop on the wall or the snake --
    tmp : snakeType := snake;
    exitFlag : boolean := false;
    y : coordType := fruit.y;
    x : coordType := fruit.x;
    width : coordType := 72;
    height: coordType := 24;
  begin
    -- check for a wall drop, move it out of the way --
    while level(x,y) /= ' ' loop
      if x < width - 2 then
	x := x + 2;
      elsif y < height then
	y := y + 1;
      else
	x := x - 1;
	y := y - 1;
      end if;
    end loop;
    -- check for a drop on the snake --
    while tmp /= NULL loop
      -- move it to the opposite end of the map and shift it --
      if tmp.x = x and then tmp.y = y then
	x := width - x;
	if x < width - 4 then
	  x := x + 4;
	else
	  if x > 8 then
	    x := x - 2;
	  end if;
	end if;
	y := height - y;
	if y < height - 3 then
	  y := y + 3;
	else
	  if y < 4 then
	    y := y -1;
	  end if;
	end if;
        -- retest wall drop --
	while level(x,y) /= ' ' loop
	  if x < width - 2 then
	    x := x + 2;
	  elsif y < height then
	    y := y + 1;
	  else
	    y := y - 1;
	    x := x - 2;
	  end if;
        end loop;
      else
	tmp := tmp.next;
      end if;
    end loop;
    fruit.x := x;
    fruit.y := y;
  end snakeWallDrop;

-------------------------------------------------------------------------------
  procedure setFruit(fruit : in out fruitType; snake : snakeType;
		     level: levelMatrix) is
    gen : generator;
    chr : integer;
  begin
    -- seed the random generator --
    reset(gen);
    -- choose the fruit type --
    chr := (random(gen) mod 1000) + 1;
    if chr < 699 then
      fruit.symbol := 'Q';
    elsif chr < 949 then
      fruit.symbol := '8';
    elsif chr < 998 then
      fruit.symbol := '#';
    else
      fruit.symbol := '?'; 
    end if;
    -- get x and y coordinates, keeping boundaries in mind --
    fruit.x := (random(gen) mod 66) + 6;
    fruit.y := (random(gen) mod 21) + 3;
    -- make sure fruit is on an even spot --
    if fruit.x mod 2 /= 0 then
      fruit.x := fruit.x + 1;
    end if;
    -- check that it doesn't drop on a wall --
    snakeWallDrop(fruit, snake, level);
--    fruit.x :=  xWallDrop(fruit, level);
--    fruit.y :=  yWallDrop(fruit, level);
  end setFruit;
  
-------------------------------------------------------------------------------
 
  procedure dropFruit(fruit : fruitType; back : colorType := black) is
  -- drop fruit to the screen --
  begin
    setBackground(back);
    -- change color depending on fruit --
    if fruit.symbol = 'Q' and then back /= yellow and then back /= white then
      setForeground(yellow);
    elsif fruit.symbol = '8' and then back /= magenta and then back /= red then
      setForeground(magenta);
    elsif fruit.symbol = '#' and then back /= cyan and then back /= blue then
      setForeground(cyan);
    elsif fruit.symbol = '?' and then back /= white and then back /= yellow then
      setForeground(white);
    else
      setForeground(black); 
    end if;
    -- change coordinates to drop point and place it --
    changeCoord(fruit.x, fruit.y);
    put(fruit.symbol);
  end dropFruit;

-------------------------------------------------------------------------------

  function testFruitCollide(snake : snakeType; fruit : fruitType) return
  integer is
  -- returns the amount of points for the fruit --
    -- stores points value --
    points : integer := 0;
  begin
    -- if snake is not null then check with fruit --
    if snake /= NULL then
      if snake.x = fruit.x and then snake.y = fruit.y then
        -- if it's an apple, 200 points --
	if fruit.symbol = 'Q' then
	  points := 200;
	  put(ascii.bel);
	-- if it's cherries, 400 points --
	elsif fruit.symbol = '8' then
	  points := 400;
	  put(ascii.bel);
	-- if it's chex mix, 1000 points --
	elsif fruit.symbol = '#' then
	  points := 1000;
	  put(ascii.bel);
        else
	  points := 3000;
	  put(ascii.bel);
	end if;
      end if;
    end if;

    return points;
  end testFruitCollide;

-------------------------------------------------------------------------------

  function returnLast return snakeType is
  -- Returns the pointer to last position of the snake --
  begin
    return last;
  end returnLast;

-------------------------------------------------------------------------------
end snakeADT;
