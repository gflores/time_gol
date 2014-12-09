#Time Travel Game of Life

Ever wanted to travel across the Multiverse ? You can now do it in the Conway's Game of Life Universe !

Conway's Game of Life: http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

I made this project in Erlang using ChicagoBoss.

##Setup

1) Install Erlang OTP 17 https://www.erlang-solutions.com/downloads/download-erlang-otp

2) Install ChicagoBoss http://www.chicagoboss.org/download.htm

3) Clone this repository and run:
  
  `./rebar get-deps`
  
  `./rebar compile`

##Launching the webserver

Just run: `./init-dev.sh`, and you should be able to go to http://localhost:8001/world_line/main

##Manual

###Flow Mode

Flow Mode is when you can manipulate time at will, and explore the multiverse.

Looks like this:

![alt text](http://puu.sh/do3YU/2db5410161.png "screenshot1")


Use these to navigate in time: ![alt text](http://puu.sh/do3t3/c619a00121.png "Buttons")

If you have ticked this: ![alt text](http://puu.sh/do3HZ/5c28fa08b9.png "Fork"), you will enter Fork Mode when you change to the next day (accelerate time forward !).

###Fork Mode

Fork Mode is when you can manipulate the world itself to create alternate realities.

Looks like this:

![alt text](http://puu.sh/do4yM/f04a7c5ebc.png "screenshot2")


Time has stopped, you can click on the dead cells to make them live and click on the live cells to make them die.

Click the Fork button ![alt text](http://puu.sh/do55k/31a1139ee3.png "Fork Button") to create a new world, and you will re-enter Flow Mode.

You can also set the name of the newly created universe: ![alt text](http://puu.sh/do5kE/37e6046335.png "Set Name")
