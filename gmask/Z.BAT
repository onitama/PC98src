echo off
	tcc -ms -1 -d -O test gint.obj gmask.obj aska.obj pal2.obj font2.obj mos.obj
	if errorlevel 1 goto tiger
	test
:tiger
