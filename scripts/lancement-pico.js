var canvas = document.getElementById("canvas");
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

// show Emscripten environment where the canvas is
// arguments are passed to PICO-8
		
var Module = {};
Module.canvas = canvas;
		
		/*
			// When pico8_buttons is defined, PICO-8 takes each int to be a live bitfield
			// representing the state of each player's buttons
			
			var pico8_buttons = [0, 0, 0, 0, 0, 0, 0, 0]; // max 8 players
			pico8_buttons[0] = 2 | 16; // example: player 0, RIGHT and Z held down
			
			// when pico8_gpio is defined, reading and writing to gpio pins will
			// read and write to these values
			var pico8_gpio = new Array(128);
		*/