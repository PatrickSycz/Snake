----------------------------------------------------------
-- Name: Patrick Sycz ------------------------------------
-- Package Description: levelADT contains all necessary --
-- function/subprogram implementations declared in the  --
-- package body.					--
----------------------------------------------------------

with game_engine, ada.text_io, ada.integer_text_io, ada.exceptions, gnat.os_lib;
use game_engine, ada.text_io, ada.integer_text_io, ada.exceptions, gnat.os_lib;

package body leveladt is

LEVELHEIGHT : CONSTANT INTEGER := 25;
LEVELWIDTH  : CONSTANT INTEGER := 80;
-------------------------------------------------------------------------------

  procedure fillMap(level : in out levelPtr; map : fileType;
		    size : integer) is
  -- fills the layout matrix --
    i      : integer := 1;
    j      : integer := 1;
    width  : integer;
    height : integer;
    file   : ada.text_io.file_Type;
  begin
    open(file, ada.text_io.in_file, map(1..size));
    get(file, width);
    get(file, height);
    level.levelWidth := width;
    level.levelHeight := height;
    while i <= height loop
      while j <= width loop
        get(File, level.layout(j,i));
        j := j + 1;
      end loop;
      j := 1;
      i := i + 1;
    end loop;
    close(file);
  end fillMap;

-------------------------------------------------------------------------------

  procedure buildLevel(level : in out levelPtr; key : integer; name : filetype;
		       size : integer) is
  -- constructs level --
  begin
    level := new levelType;
    level.number := key;
    level.height := 1;
    level.name := name;
    level.size := size;
    fillMap(level, name, size);
    level.left := null;
    level.right := null;
  end buildLevel;

-------------------------------------------------------------------------------

  function max(a,b : integer) return integer is
  -- returns max integer --
  begin
    if a < b then
      return b;
    else
      return a;
    end if;
  end max;

-------------------------------------------------------------------------------

  function height(level : levelPtr) return integer is
  -- returns height of a node --
  begin
    if level = null then
      return 0;
    else
      return level.height;
    end if;
  end height;

-------------------------------------------------------------------------------

  procedure rotateRight(levels : in out levelPtr) is
  -- rotates the right side of the tree  --
    tmp : levelPtr := levels.right;
  begin
--    put_line("ROTATED RIGHT ");
    levels.right := tmp.left;
    tmp.left := levels;
    levels.height := max(height(levels.right), height(levels.left)) + 1;
    tmp.height := max(height(tmp.left), height(tmp.right)) + 1;
    levels := tmp;
  end rotateRight;

-------------------------------------------------------------------------------

  procedure rotateLeft(levels : in out levelPtr) is
  -- rotates the left side of the tree --
    tmp : levelPtr := levels.left;
  begin
--    put_line("ROTATED LEFT ");
    levels.left := tmp.right;
    tmp.right := levels;
    levels.height := max(height(levels.right), height(levels.left)) + 1;
    tmp.height := max(height(tmp.left), height(tmp.right)) + 1;
    levels := tmp;
  end rotateLeft;

-------------------------------------------------------------------------------

  procedure rotateRightLeft(levels : in out levelPtr) is
  -- rotates right side then left side --
  begin
    rotateRight(levels.left);
    rotateLeft(levels);
  end rotateRightLeft;
  
-------------------------------------------------------------------------------

  procedure rotateLeftRight(levels : in out levelPtr) is
  -- rotates left side then right side --
  begin
    rotateLeft(levels.right);
    rotateRight(levels);
  end rotateLeftRight;

-------------------------------------------------------------------------------

  procedure insert(key : integer; name : fileType; size : integer;
		   levels : in out levelPtr) is
  -- inserts levels into the level tree --
  begin
    if levels = NULL then
      buildLevel(levels, key, name, size);
    
    elsif key < levels.number then
      insert(key, name, size, levels.left);

    elsif levels.number < key then
      insert(key, name, size, levels.right);
    end if;
    if height(levels.left)-height(levels.right) = 2 then
      if key < levels.left.number then
        rotateLeft(levels);
      else 
        rotateRightLeft(levels);
      end if;
    elsif height(levels.right) - height(levels.left) = 2 then
      if levels.right.number < key then
        rotateRight(levels);
      else
        rotateLeftRight(levels);
      end if;
    else
      levels.height := max(height(levels.left), height(levels.right)) + 1;
    end if;

  end insert;

-------------------------------------------------------------------------------
  procedure load(levels : in out levelPtr) is
  -- reads level list from a file and inserts them into a level tree --
    header    : ada.text_io.file_Type;
    stage     : ada.text_io.file_type;
    width     : coordType;
    height    : coordType;
    numbers   : integer;
    stageName : fileType;
    nameSize  : integer;
  begin
    open(header, in_file, "levels/level_info.dat");
    get(header, width);
    get(header, height);
    get(header, numbers);
    skip_line(header);
    for i in 1..numbers loop
      get_line(header, stageName, nameSize);
      nameSize := nameSize + 7;
      stageName(8..nameSize) := stageName(1..(nameSize - 7));
      stageName(1..7) := "levels/";
      insert(i, stageName, nameSize, levels);
    end loop;
    close(header);
  end load;

-------------------------------------------------------------------------------

  procedure displayOptions(mode:in out integer; BC,WC,SC,SB:in out colorType) is
    optionsFile   : file_Type; 		-- file reference     --
    width, height : integer := 0;	-- window dimension   --
    fileName      : fileType;		-- filename 	      --
    size, max, hi : integer := 17;	-- dimension set 2    --
    options       : levelPtr;		-- options map        --
    choice        : character := '0';	-- choice input       --
    exitFlag      : boolean := FALSE;   -- exit flag for loop --

    type choiceType is array (1..8) of string(1..8); --Array holds choices --
    difficulty, color : choiceType;

    modeChoice : integer := 2;  -- indices for menus --
    bcChoice   : integer := 1;
    wcChoice   : integer := 4;
    scChoice   : integer := 6;
    sbChoice   : integer := 1;
    index      : integer;

  begin
    -- open file, get contents, create a map --
    fileName(1..size) := "title/options.dat";
    open(optionsFile, in_File, fileName(1..size));
    get(optionsFile, width);
    get(optionsFile, height);
    close(optionsFile);
    options := new levelType;
    fillMap(options, fileName, size);

    -- display the map --
    changeCoord(1,1);
    setBackground(black);
    setForeground(red);
    for i in 1..height loop
      for j in 1..width loop
        changeCoord(j,i);
	put(options.layout(j,i));
      end loop;
    end loop;

    -- set choices parameters --
    difficulty(1) := " Easy   ";
    difficulty(2) := " Medium ";
    difficulty(3) := " Hard   ";
    
    color(1) := " Black  ";
    color(2) := " White  ";
    color(3) := " Blue   ";
    color(4) := " Red    ";
    color(5) := " Yellow ";
    color(6) := " Green  ";
    color(7) := " Cyan   ";
    color(8) := " Magenta";

    max := height;
    width := (width/2) + 2;
    setForeground(yellow);
    index := (height / 2) - 2;
    while not exitFlag loop
      setForeground(yellow);
      hi := (height / 2) - 2;
      -- display choices --
      changeCoord(width, hi);
      put(difficulty(modeChoice));
      hi := hi + 1;
      changeCoord(width, hi);
      put(color(bcChoice));
      hi := hi + 1;
      changeCoord(width, hi);
      put(color(wcChoice));
      hi := hi + 1;
      changeCoord(width, hi);
      put(color(scChoice));
      hi := hi + 1;
      changeCoord(width, hi);
      put(color(sbChoice));
      hi := hi + 1;
      changeCoord(width, hi);
      put(" Exit");
      changeCoord(width - 1, index);
      setForeground(cyan);
      put('>');
    -- get choices --
      while choice /= ' ' loop
        get_immediate(choice);
        if (choice='i' or else choice= 'A')and then index > ((max/2) - 2) then
	  changeCoord(width - 1, index);
	  put(' ');
          index := index - 1;
          changeCoord(width - 1, index);
	  put('>');
        elsif (choice='k' or else choice='B')and then index < ((max/2) + 3) then
	  changeCoord(width - 1, index);
	  put(' ');
          index := index + 1;
	  changeCoord(width - 1, index);
	  put('>');
        end if;
      end loop;

      -- play sound and change menu --
      -- change difficulty --
      if index = ((max / 2) - 2) then
        if modeChoice < 3 then
          modeChoice := modeChoice + 1;
        else 
	  modeChoice := 1;
	end if;
        index := (max / 2) - 2;

      -- change background color --
      elsif index = ((max / 2) - 1) then
        if bcChoice < 8 then
	  bcChoice := bcChoice + 1;
	else
	  bcChoice := 1;
	end if;
        index := (max / 2) - 1;
      
      -- change wall color --
      elsif index = ((max / 2)) then
        if wcChoice < 8 then
	  wcChoice := wcChoice + 1;
	else
	  wcChoice := 1;
	end if;
        index := (max / 2);

      -- change snake color --
      elsif index = ((max / 2) + 1) then
        if scChoice < 8 then
	  scChoice := scChoice + 1;
	else
	  scChoice := 1;
	end if;
        index := (max / 2) + 1;

      -- change snake background --
      elsif index = ((max / 2) + 2) then
        if sbChoice < 8 then
	  sbChoice := sbChoice + 1;
	else
	  sbChoice := 1;
	end if;
        index := (max / 2) + 2;
 
      -- exit menu --
      elsif index = ((max / 2) + 3) then
        exitFlag := TRUE;
        put(ascii.bel);
      else
        return;
      end if;
      -- reset choice --
      choice := '0';
    end loop;

    -- set all game attributes --
    mode := modeChoice;
    case bcChoice is
	when 1 => BC := black;
        when 2 => BC := white;
	when 3 => BC := blue;
	when 4 => BC := red;
	when 5 => BC := yellow;
	when 6 => BC := green;
	when 7 => BC := cyan;
	when 8 => BC := magenta;
        when others => BC := black;
    end case;

    case wcChoice is
	when 1 => WC := black;
        when 2 => WC := white;
	when 3 => WC := blue;
	when 4 => WC := red;
	when 5 => WC := yellow;
	when 6 => WC := green;
	when 7 => WC := cyan;
	when 8 => WC := magenta;
	when others => WC := red;
    end case;

    case scChoice is
	when 1 => SC := black;
        when 2 => SC := white;
	when 3 => SC := blue;
	when 4 => SC := red;
	when 5 => SC := yellow;
	when 6 => SC := green;
	when 7 => SC := cyan;
	when 8 => SC := magenta;
	when others => SC := green;
    end case;

    case sbChoice is 
	when 1 => SB := black;
        when 2 => SB := white;
	when 3 => SB := blue;
	when 4 => SB := red;
	when 5 => SB := yellow;
	when 6 => SB := green;
	when 7 => SB := cyan;
	when 8 => SB := magenta;
	when others => SB := black;
    end case;

  end displayOptions;
    
-------------------------------------------------------------------------------

  -- title menu actions --
  procedure displayTitle(key : in out character; mode : in out integer; 
		         BC, WC, SC, SB : in out colorType) is
    titleFile : ada.text_io.file_type;
    width     : coordType;
    height    : coordType;
    title     : levelPtr;
    fileName  : fileType;
    size      : integer := 15;
    choice    : character := '0';
    max       : coordType;
  begin

    fileName(1..size) := "title/title.txt";
    title := new levelType;
    fillMap(title, fileName, size);

    <<startMenu>>
    open(titleFile, ada.text_io.in_File, fileName);
    get(titleFile, width);
    get(titleFile, height);
    close(titleFile);

    -- display the title screen --

    choice := '0';
    changeCoord(1,1);
    setBackground(black);
    setForeground(cyan);
    for i in 1..height loop
      for j in 1..width loop
        changeCoord(j,i);
        put(title.layout(j,i));
      end loop;
      new_line;
    end loop;
 
    -- display choices --
    max := height;
    width := (width/2) - 5;
    height := height/2 + 6;
    setForeground(yellow);
    changeCoord(width, height);
    height := height + 1;
    put(" Play Game");
    changeCoord(width, height);
    height := height + 1;
    put(" Options");
    changeCoord(width, height);
    put(" Exit");
    changeCoord(width - 1, height);
    setForeground(cyan);
    put('>');
    -- get choice --
    while choice /= ' ' loop
      get_immediate(choice);
      if (choice = 'i' or else choice = 'A')and then height > ((max/2) + 6) then
	changeCoord(width - 1, height);
	put(' ');
        height := height - 1;
        changeCoord(width - 1, height);
	put('>');
      elsif (choice = 'k' or else choice='B')and then height < ((max/2) + 8) then
	changeCoord(width - 1, height);
	put(' ');
        height := height + 1;
	changeCoord(width - 1, height);
	put('>');
      end if;
    end loop;

    -- play sound and return choice --
    put(ascii.bel);
    if height = ((max / 2) + 6) then
      key := 'p';
    elsif height = ((max / 2) + 7) then
      displayOptions(mode, BC, WC, SC, SB);--(mode);
      goto startMenu;
    elsif height = ((max / 2) + 8) then
      key := ascii.esc;
    else
      return;
    end if; 
  end displayTitle;

-------------------------------------------------------------------------------

  function getLevel(levels : levelPtr; key : integer) return levelMatrix is
    emptyMatrix : levelMatrix;
  begin
    if levels /= NULL then 
      if levels.number = key then
        return levels.layout;
      elsif levels.number < key then
	return getLevel(levels.right, key);
      elsif key < levels.number then 
	return getLevel(levels.left, key);
      else
        return emptyMatrix;
      end if;
    else
      for i in 1..LEVELHEIGHT loop
        for j in 1..LEVELWIDTH LOOP
          emptyMatrix(j,i) := ' ';
        end loop;
      end loop;
      return emptyMatrix;
    end if;
  end getLevel;

-------------------------------------------------------------------------------

  procedure displayLevel(layout : levelMatrix; fore: colorType;
			 back: colorType) is
  -- displays the level --
  begin
    -- set the foreground and background colors --
    setForeground(fore);
    setBackground(back);
    -- output each matrix cell --
    for i in 1..LEVELHEIGHT loop
      changeCoord(1,i);
      for j in 1..LEVELWIDTH loop
	put(layout(j,i));
      end loop;
    end loop;
  end displayLevel;
    
-------------------------------------------------------------------------------

  -- pauses the game --
  procedure pause(key : in out character) is
--    key : character;
    go  : boolean;
  begin
    setBackground(black);
    setForeground(white);
    changeCoord(2, LEVELHEIGHT + 1);
    put("PAUSE            ");
    changeCoord(1, 1);
    loop
      begin -- check validation --
        get_immediate(key,go);
        if go = true then
 	  get_immediate(key,go);
	  get_immediate(key,go);
	  get_immediate(key,go);
          exit;
        end if;
      exception
	when constraint_error => 
 	  while go loop
	    get_immediate(key, go);
	  end loop;
	  put("INVALID ENTRY, PRESS ENTER TO CONTINUE");
      end; -- end validation --
    end loop;
  end pause;

-------------------------------------------------------------------------------

  procedure displayHighScores(score : in out integer) is
  -- displays the high scores, inserts any high scorers, redisplays --
    
    -- local variables --
    highScores : ada.text_io.file_Type;	-- filetype for high scores --
    count      : integer := 10;		-- number of scores to store--
    width      : integer := 80;		-- width of the screen	    --
    height     : integer := 25;		-- height of the screen	    --
    extraKeys  : character;
    keysLeft   : boolean := TRUE;
    -- scoreType --
    type scoreType is record
      name : string(1..40);	-- stores player name  --
      size : integer;		-- stores size of name --
      score: integer;		-- stores player score --
    end record;
    -- type array of score types --
    type score_List is array (1..20) of scoreType;

    j	      : integer := 1;		-- counter	  --
    scoreList : score_List;		-- list of scores --
    x	      : coordType;		-- x coordinate   --
    y         : coordType;	        -- y coordinate   --
    
    -- elements to run scripts --
    Args     : Argument_list(1..0);	   	-- no arguments          --
    showText : string(1..8) := "showtext"; 	-- script to show text   --
    hideText : string(1..8) := "hidetext";	-- script to hide text   --
    passed   : boolean;				-- false if script fails --

  begin
    while keysleft loop
      get_immediate(extrakeys, keysleft);
    end loop; 
    -- open the high scores file, read in window parameters, skip to scores --
    <<ReadData>>
    begin
      open(highScores, in_File, "levels/high_scores.dat");
      get(highScores, width);
      get(highScores, height);
      get(highScores, count);
      skip_line(highScores);
      -- loop through transfering scores from file into list --
      for i in 1..count loop
        get(highScores, scoreList(i).score);
        get_line(highScores, scoreList(i).name, scoreList(i).size);
      end loop;
      close(highScores);
    exception
      when status_error => close(highScores);
      when others =>
        create(highScores, out_file, "levels/high_scores.dat");
        put(highScores, 80, 0);
        put(highScores, " ");
        put(highScores, 25, 0);
        put(highScores, " ");
        put(highScores, 10, 0);
        new_line(highScores);
        for i in 1..10 loop
	  put(highScores, 100, 0);
	  put(highScores, "AAA");
	  new_line(highScores);
        end loop;
        new_line(highScores);
	close(highScores);
	goto ReadData;
    end;

    -- display the scores, checking for possible insert --
    x := (width / 2) - 7;
    y := 5;
    changeCoord(x, y);
    setForeground(red);
    put("HIGH SCORES!:");
    x := x - 8;
    y := y + 2;
    while j <= count loop
      changeCoord(x, y + j);
      setForeground(red);
      if Score < scoreList(j).score then
        put(scoreList(j).score, 7);
        put(" ");
        setForeGround(cyan);
	put_line(scoreList(j).name(1..scoreList(j).size));
      else
        scoreList(j + 1..count + 1) := scoreList(j..count);
        scoreList(j).score := score;
        put(score, 7);
        put(" CONGRATULATIONS, ");
	changeCoord(x-10, y + 1 + j);
	put(" ENTER YOUR NAME: ");
        spawn("showtext", args, passed);
	get_line(scoreList(j).name, scoreList(j).size);
	spawn("hidetext", args, passed);
	score := 0;
      end if;
      j := j + 1;
    end loop;
    resetTerminal;
    -- display the finalized list --
    j := 1;
    x := x + 8;
    y := y - 2;
    changeCoord(x, y);
    setForeGround(red);
    put("HIGH SCORES:");
    x := x - 8;
    y := y + 2;
    while j <= count loop
      changeCoord(x, y  + j);
      setForeGround(red);
      put(scoreList(j).score, 7);
      put(" ");
      setForeground(cyan);
      put(scoreList(j).name(1..scorelist(j).size));
      j := j + 1;
    end loop;
    changeCoord(1,1);

    -- create a new high scores file --
    create(highScores, out_File, "levels/high_scores.dat");
    put(highScores, width, 0);
    put(highScores, " ");
    put(highScores, height, 0);
    put(highScores, " ");
    put(highScores, count, 0);
    new_line(highScores);
    for i in 1..count loop
      put(highScores, scoreList(i).score, 0);
      put_line(highScores, scoreList(i).name(1..scoreList(i).size));
    end loop;
    close(highScores);
    
    get_line(scoreList(12).name, scoreList(12).size);
    score := 0;
  end displayHighScores;

------------------------------------------------------------------------------- 
end leveladt;
