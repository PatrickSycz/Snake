--------------------------------------------------------------
-- Name: Patrick Sycz ----------------------------------------
-- Pacakge Descrition: Spec - contains the declarations for --
-- functions/subprograms to be performed on snake/fruit types-
--------------------------------------------------------------

with ada.text_io, ada.integer_text_io, game_engine, leveladt;
use ada.text_io, ada.integer_text_io, game_engine, leveladt;

package snakeADT is

  -- snake type --
  type snakeNode;
  type snakeType is access snakeNode;
  type snakeNode is record
    symbol : character := '@';	-- the snake body segment --
    x      : coordType;		-- x position 		  --
    y      : coordType;		-- y position		  --
    next   : snakeType;		-- pointers to other snake--
    prev   : snakeType;		-- segments		  --
  end record;

  -- fruit type --
  type fruitType is record
    symbol : character;		-- fruit symbol --
    x      : coordType;		-- x position   --
    y      : coordType;		-- y position	--
  end record;
  -- Set snake to initial length values --
  procedure initialize(snake : in out snakeType);
  -- grows snake by a given amount --
  procedure growSnake(snake : in out snakeType; amount : integer);
  -- tests for collision with itself --
  function testSelfCollide(snake : snakeType)
  return boolean;
  -- tests for collision with a wall --
  function testWallCollide(snake : snakeType; layout : levelMatrix)
  return boolean;
  -- get random fruit --
  procedure setFruit(fruit : in out fruitType; snake: snakeType; 
		     level : levelMatrix);
  -- drop fruits to the screen --
  procedure dropFruit(fruit : fruitType; back : colorType := black);
  -- returns 0 if no collision, positive integer if collision with fruit --
  function testFruitCollide(snake : snakeType; fruit : fruitType)
  return integer;
  -- move the snake --
  procedure moveSnake(snake: in out snakeType; xChange, yChange: coordType);
  -- display the snake --
  procedure displaySnake(snake : snakeType; fore: colorType := green;
			 back: colorType := black);
  -- returns the last position of the snake --
  function returnLast return snakeType;
end snakeADT;
