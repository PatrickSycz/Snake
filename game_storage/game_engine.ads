---------------------------------------------------------------------
-- Patrick Sycz -----------------------------------------------------
-- Professor Hagerich -----------------------------------------------
-- Data Structures --------------------------------------------------
-- Game_Engine: A tool designed for ultimate terminal manipulation --
-- This is done with escape sequencing and is open source to any   --
-- who want to use it. Updates will come soon -----------------------
---------------------------------------------------------------------
package game_engine is

-- Colors for the terminal --
type colorType is (red, blue, green, magenta, cyan, yellow, white, black,
		   boldRed, boldBlue, boldGreen, boldMagenta, boldCyan, 
		   boldYellow, boldWhite, boldBlack);

-- max range for terminal values --
subtype coordType is integer range -200..200;

-- exception out of bounds --
--exception out_of_bounds;

procedure resetTerminal;
-------------------------------------------------------------------------------
-- Clears the terminal screen from the bottom up ------------------------------
-------------------------------------------------------------------------------

procedure changeCoord(x,y : coordType);
-------------------------------------------------------------------------------
-- Place cursor at the (x,y) coordinates --------------------------------------
-------------------------------------------------------------------------------
procedure setForeground(color : colorType);
-------------------------------------------------------------------------------
-- Changes the color of the text being used -----------------------------------
-------------------------------------------------------------------------------

procedure setBackground(color : colorType);
-------------------------------------------------------------------------------
-- Changes the color of the background ----------------------------------------
-------------------------------------------------------------------------------

end game_engine;
