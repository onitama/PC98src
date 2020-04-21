echo off
	tcc -ms -1 test mgint.obj gstring.obj
	if errorlevel 1 goto tiger
	test /t1 /c test1
:tiger
