# GML-Marching-Squares
A simple and pure Marching Squares implantation for GameMaker Studio 2.3

![Marching Squares](https://github.com/SnowSnakz/GML-Marching-Squares/blob/main/MarchingSquares.gif?raw=true)

## What is it?
Marching Squares is the 2D equivalent to Marching Cubes, which was an algorithm originally designed to visualize medical scans.

Marching Cubes has more uses outside of the medical field though, a really common use-case for marching cubes in video games is Terrain.

A typical video game terrain would use something called a heightmap which is a list of values denoting the height of the terrain at a specific value.

While heightmap terrains are incredibly useful and generally OK, they have one big caveot. Caves, Overhangs and 90degree angles (cliffs) are impossible to do with that setup.

Marching Cubes provides a solution to that problem, instead of a 2D grid of height values, we have a 3D grid of density values. Marching Cubes will generate a water-tight mesh encompassing all of the areas where the density is above or below a certain threshold (the isovalue.)

I wrote an implementation of this a long while back, you can find that [here](https://github.com/SnowSnakz/MarchingSquaresGM). This implementation takes in a DS_Grid and outputs a DS_List of LINES, I've wanted to rewrite this algorithm for a while, to boost it's speed and also to support outputting triangles instead of just lines.

## How does it work?
[I feel like wikipedia](https://en.wikipedia.org/wiki/Marching_squares) has already done a fantastic job of explaining this algorithm.

If you just want a simple breakdown of the general idea, I made a little graphic to showcase it.\
The graphic below also shows the triangles that are generated with my implementation.
![Marching Squares Graphic](https://github.com/SnowSnakz/GML-Marching-Squares/blob/main/marching_squares_poster-export.png?raw=true)

## Is it fast enough to use in real-time?
That mostly depends on what the size of your grid is.\
On modern medium-end hardware it should be fast enough for real-time applications.\
You should store the generated mesh in a vertex buffer or surface, and you only need to update that mesh when changes are made.
