echo off
	tcc -ms -1 -d -O test aska3.obj owb2.obj mos.obj vtx.obj
	if errorlevel 1 goto tiger
	REM test cg
:tiger
