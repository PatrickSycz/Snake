build:
	gnatmake -gnatc game_storage/snakeadt.ads
	gnatmake game_storage/snakeadt.adb
	gnatmake -gnatc game_storage/leveladt.ads
	gnatmake game_storage/leveladt.ads
	gnatmake game_storage/snake.adb
	rm -f game_storage/object_files/*.ali core 
	rm -f game_storage/object_files/*.o core
	rm -f game_storage/snake
	mv *.ali game_storage/object_files/
	mv *.o game_storage/object_files/
	mv snake game_storage/
	cp game_storage/play_snake play_snake
clean:
	rm -f game_storage/snake
	rm -f game_storage/object_files/*.ali core
	rm -f game_storage/object_files/*.o core
debug: 
	gnatmake -gnatc -g game_storage/snakeadt.ads
	gnatmake -g game_storage/snakeadt.adb
	gnatmake -gnatc -g game_storage/leveladt.ads
	gnatmake -g game_storage/leveladt.adb
	gnatmake -g game_storage/snake.adb
	rm -f debug/*.ali debug/*.o
	mv *.o debug/
	mv *.ali debug/
	mv snake debug 
