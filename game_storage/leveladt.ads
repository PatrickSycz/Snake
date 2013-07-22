----------------------------------------------------------
-- Name: Patrick Sycz ------------------------------------
-- Package Decription: Specification for levelADT. Shows--
-- all the subprograms/functions available to use. 	--
----------------------------------------------------------
with game_engine;
use game_engine;

package leveladt is
  -- type of string that holds filenames --
  subtype fileType is string(1..50);
  -- tree type to store levels --
  type levelType;
  type levelPtr is access levelType;
  type levelMatrix is array(1..80,1..25) of character;
  type levelType is record
    number 	: integer;	-- level number 	--
    height 	: integer;	-- height of tree	--
    name 	: fileType;	-- level's file name	--
    size  	: integer;	-- size of 'name'	--
    layout 	: levelMatrix;	-- stores wall/whitespace-
    levelWidth  : integer;	-- width (in characters)--
    levelHeight : integer;	--height (in characters)--
    left   	: levelPtr;	-- pointers to other levels
    right  	: levelPtr;
  end record;

  -- loads levels into a tree --
  procedure load(levels : in out levelPtr);
  -- displays tree, takes a layout, wallcolor and background color --
  procedure displayLevel(layout : in levelMatrix; fore: colorType;
			  back : colorType);
  -- pauses the game --
  procedure pause(key : in out character);
  -- displays the titlescreen and initializes game settings --
  procedure displayTitle(key : in out character; mode : in out integer;
			 BC, WC, SC, SB : in out colorType);
  -- shows the high score screen, resets the score --
  procedure displayHighScores(score : in out integer);
  -- returns the layout of a level --
  function getLevel(levels : levelPtr; key : integer) return levelMatrix;

end leveladt;
