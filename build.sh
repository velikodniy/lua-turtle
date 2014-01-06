#!/bin/sh
valac --target-glib=2.32 --thread\
	--pkg gtk+-3.0\
	--pkg gmodule-2.0\
	--pkg gtksourceview-3.0\
	--pkg lua\
	-X "-I/usr/include/lua5.2" -X "-llua5.2" -X "-lm"\
	main.vala Plotter.vala Turtle.vala\
	-o turtle
