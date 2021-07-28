bool IsUsingItem(int scriptid) //Function to detect item usage
{
	if ((Input->Button[CB_A] && G[G_BUTTON_A] == scriptid)
	|| (Input->Button[CB_B] && G[G_BUTTON_B] == scriptid)
	|| (Input->Button[CB_L] && G[G_BUTTON_L] == scriptid)
	|| (Input->Button[CB_R] && G[G_BUTTON_R] == scriptid)) return true;
	else return false;
}

bool IsPressingItem(int scriptid) //Function to detect item pressage
{
	if ((Input->Press[CB_A] && G[G_BUTTON_A] == scriptid)
	|| (Input->Press[CB_B] && G[G_BUTTON_B] == scriptid)
	|| (Input->Press[CB_L] && G[G_BUTTON_L] == scriptid)
	|| (Input->Press[CB_R] && G[G_BUTTON_R] == scriptid)) return true;
	else return false;
}

void DrawBox(int layer, int tile, int cset, int x, int y, int width, int height, int opacity) //Draws a box/frame via tiles. Uses a 3x3 grid of tiles.
{
	unless (width <  2 || height < 2)
	{
		int x3 = x+((width-1)*16);
		int y3 = y+((height-1)*16);
		for (int x2 = x; x2 <= x3; x2+=16) 
		{
			for (int y2 = y; y2 <= y3; y2+=16)
			{
				if (x2 == x)
				{
					if (y2 == y) Screen->FastTile(layer, x2, y2, tile, cset, opacity);
					else if (y2 == y3) Screen->FastTile(layer, x2, y2, tile+40, cset, opacity);
					else Screen->FastTile(layer, x2, y2, tile+20, cset, opacity);
				}
				else if (x2 == x3)
				{
					if (y2 == y) Screen->FastTile(layer, x2, y2, tile+2, cset, opacity);
					else if (y2 == y3) Screen->FastTile(layer, x2, y2, tile+42, cset, opacity);
					else Screen->FastTile(layer, x2, y2, tile+22, cset, opacity);
				}
				else
				{
					if (y2 == y) Screen->FastTile(layer, x2, y2, tile+1, cset, opacity);
					else if (y2 == y3) Screen->FastTile(layer, x2, y2, tile+41, cset, opacity);
					else Screen->FastTile(layer, x2, y2, tile+21, cset, opacity);
				}
			}
		}
	}
}

/*
Draws a box/frame using tile scaling to either the screen or a bitmap of your choice. This requires three tiles. Lighter on resources and tile space but lacks the ability to make any complicated systems.
layer - Layer to draw on
target - Target bitmap.
tiles - The metadata of the corner tiles the frame uses. Pass an array of at least size 3 to use. The indicies should be formatted like this:
	{cornertile, cornerw, cornerh}
	The horizontal tiles, cornertile+1, should have a graphic that's 16 pixels wide and should be positioned on the top edge of the tile.
	The vertical tiles, cornertile+2, should have a graphic that's 16 pixels long and should be positioned on the left edge of the tile.
cset - CSet for the frame to be drawn in.
boxcolor - The colour of the interior of the box. Leave it if you don't need it drawn
x - X position to draw the box at
y - Y position to draw the box at
width - width of the box
height - height of the box
opacity - opacity of the whole box. Supply an array of at least Size 2 to use. The indicies should be formatted like this:
	{frameopacity, boxopacity}
*/
void DrawBoxScale(int layer, bitmap target, int tiles, int cset, int boxcolor, int x, int y, int width, int height, int opacity) 
{
	width = Max(width, tiles[1]*2);
	height = Max(height, tiles[2]*2);
	//Draw the interior of the box first if the selected colour is valid and not translucent
	if(boxcolor > 0x00 && boxcolor <= 0xFF)
		target->Rectangle(layer, x+tiles[1], y+tiles[2], x+width-tiles[1], y+height-tiles[2], boxcolor, -1, 0, 0, 0, true, opacity[1]);
	//Draw the horizontal pieces
	target->DrawTile(layer, x+tiles[1], y, tiles[0]+1, 1, 1, cset, width-tiles[1]*2, 16, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Top
	target->DrawTile(layer, x+tiles[1], y+height-16, tiles[0]+1, 1, 1, cset, width-tiles[1]*2, 16, 0, 0, 0, FLIP_VERTICAL, true, opacity[0]); //Bottom
	//Draw the vertical pieces
	target->DrawTile(layer, x, y+tiles[2], tiles[0]+2, 1, 1, cset, 16, height-tiles[2]*2, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Left
	target->DrawTile(layer, x+width-16, y+tiles[2], tiles[0]+2, 1, 1, cset, 16, height-tiles[2]*2, 0, 0, 0, FLIP_HORIZONTAL, true, opacity[0]); //Right
	//Draw the corner pieces
	target->DrawTile(layer, x, y, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Top left
	target->DrawTile(layer, x+width-16, y, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_HORIZONTAL, true, opacity[0]); //Top right
	target->DrawTile(layer, x, y+height-16, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_VERTICAL, true, opacity[0]); //Bottom left
	target->DrawTile(layer, x+width-16, y+height-16, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_BOTH, true, opacity[0]); //Bottom right
}

//Draws to the screen instead of a bitmap
void DrawBoxScale(int layer, int tiles, int cset, int boxcolor, int x, int y, int width, int height, int opacity) 
{
	width = Max(width, tiles[1]*2);
	height = Max(height, tiles[2]*2);
	//Draw the interior of the box first if the selected colour is valid and not translucent
	//Draw the interior of the box first if the selected colour is valid and not translucent
	if(boxcolor > 0x00 && boxcolor <= 0xFF)
		Screen->Rectangle(layer, x+tiles[1], y+tiles[2], x+width-tiles[1], y+height-tiles[2], boxcolor, -1, 0, 0, 0, true, opacity[1]);
	//Draw the horizontal pieces
	Screen->DrawTile(layer, x+tiles[1], y, tiles[0]+1, 1, 1, cset, width-tiles[1]*2, 16, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Top
	Screen->DrawTile(layer, x+tiles[1], y+height-16, tiles[0]+1, 1, 1, cset, width-tiles[1]*2, 16, 0, 0, 0, FLIP_VERTICAL, true, opacity[0]); //Bottom
	//Draw the vertical pieces
	Screen->DrawTile(layer, x, y+tiles[2], tiles[0]+2, 1, 1, cset, 16, height-tiles[2]*2, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Left
	Screen->DrawTile(layer, x+width-16, y+tiles[2], tiles[0]+2, 1, 1, cset, 16, height-tiles[2]*2, 0, 0, 0, FLIP_HORIZONTAL, true, opacity[0]); //Right
	//Draw the corner pieces
	Screen->DrawTile(layer, x, y, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_NONE, true, opacity[0]); //Top left
	Screen->DrawTile(layer, x+width-16, y, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_HORIZONTAL, true, opacity[0]); //Top right
	Screen->DrawTile(layer, x, y+height-16, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_VERTICAL, true, opacity[0]); //Bottom left
	Screen->DrawTile(layer, x+width-16, y+height-16, tiles[0], 1, 1, cset, -1, -1, 0, 0, 0, FLIP_BOTH, true, opacity[0]); //Bottom right
}

npc GetEnemy()	//Gets a valid, beatable enemy
{
	unless(EnemiesAlive()) return NULL;
	npc enemy;
	until (enemy)
	{
		enemy = Screen->LoadNPC(Rand(1, Screen->NumNPCs()));
		unless (isTargetable(enemy)) enemy = NULL;
	}
	return enemy;
}

bool isTargetable(npc enemy) //Checks if an enemy is beatable
{
	return (((enemy->MiscFlags&NPCMF_NOT_BEATABLE) || enemy->Type == NPCT_FAIRY || enemy->Type == NPCT_GUY) ? false : true);
}

//Checks if the coordinates are onscreen
bool isOnScreen(int x, int y)
{
	return (x >= SCREEN_LEFT && x <= SCREEN_RIGHT && y >= SCREEN_TOP && y <= SCREEN_BOTTOM);
}

//Safe Arc, for screens
void SafeArc(int layer, int x, int y, int radius, int startangle, int endangle, int color, float scale, int rx, int ry, int rangle, bool closed, bool fill, int opacity)
{
	if (startangle > endangle)
	{
		int temp = startangle;
		startangle = endangle;
		endangle = temp;
	}
	int cx = x;
	int cy = y;
	int r = radius;
	unless (scale == 1) r*=scale;
	if(rangle!=0) //rotation
	{	
		cx=rx + (Cos(rangle) * (cx - rx) - Sin(rangle) * (cy - ry));     //x1
		cy=ry + (Sin(rangle) * (cx - rx) + Cos(rangle) * (cy - ry));     //y1
		endangle-=rangle;
		startangle-=rangle;
	}
	int fx=cx+(Cos(-(endangle+startangle)/2)*radius/2);
	int fy=cy+(Sin(-(endangle+startangle)/2)*radius/2);
	if (fx >= 0 && fy >= 0 && fx < 256 && fy < 168 && (Abs(startangle-endangle) > 2 || radius >20)) Screen->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, fill, opacity);
	else Screen->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, false, opacity);
}

void SafeArc2(int layer, int x, int y, int radius, int startangle, int endangle, int color, float scale, int rx, int ry, int rangle, bool closed, bool fill, int opacity)
{
	startangle = 360 - startangle;
	endangle = 360 - endangle;
	if (startangle > endangle)
	{
		int temp = startangle;
		startangle = endangle;
		endangle = temp;
	}
	int cx = x;
	int cy = y;
	int r = radius;
	unless (scale == 1) r*=scale;
	if(rangle!=0) //rotation
	{	
		cx=rx + (Cos(rangle) * (cx - rx) - Sin(rangle) * (cy - ry));     //x1
		cy=ry + (Sin(rangle) * (cx - rx) + Cos(rangle) * (cy - ry));     //y1
		endangle-=rangle;
		startangle-=rangle;
	}
	int fx=cx+(Cos(-(endangle+startangle)/2)*radius/2);
	int fy=cy+(Sin(-(endangle+startangle)/2)*radius/2);
	if (fx >= 0 && fy >= 0 && fx < 256 && fy < 168 && (Abs(startangle-endangle) > 2 || radius >20)) Screen->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, fill, opacity);
	else Screen->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, false, opacity);
}

//Safe Arc, for bitmaps
void SafeArc(bitmap bmp, int layer, int x, int y, int radius, int startangle, int endangle, int color, float scale, int rx, int ry, int rangle, bool closed, bool fill, int opacity)
{
	if (startangle > endangle)
	{
		int temp = startangle;
		startangle = endangle;
		endangle = temp;
	}
	int cx = x;
	int cy = y;
	int r = radius;
	unless (scale == 1) r*=scale;
	if(rangle!=0) //rotation
	{	
		cx=rx + (Cos(rangle) * (cx - rx) - Sin(rangle) * (cy - ry));     //x1
		cy=ry + (Sin(rangle) * (cx - rx) + Cos(rangle) * (cy - ry));     //y1
		endangle-=rangle;
		startangle-=rangle;
	}
	int fx=cx+(Cos(-(endangle+startangle)/2)*radius/2);
	int fy=cy+(Sin(-(endangle+startangle)/2)*radius/2);
	if (fx >= 0 && fy >= 0 && fx < bmp->Width && fy < bmp->Height && (Abs(startangle-endangle) > 2 || radius >20)) bmp->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, fill, opacity);
	else bmp->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, false, opacity);
}

void SafeArc2(bitmap bmp, int layer, int x, int y, int radius, int startangle, int endangle, int color, float scale, int rx, int ry, int rangle, bool closed, bool fill, int opacity)
{
	startangle = 360 - startangle;
	endangle = 360 - endangle;
	if (startangle > endangle)
	{
		int temp = startangle;
		startangle = endangle;
		endangle = temp;
	}
	int cx = x;
	int cy = y;
	int r = radius;
	unless (scale == 1) r*=scale;
	if(rangle!=0) //rotation
	{	
		cx=rx + (Cos(rangle) * (cx - rx) - Sin(rangle) * (cy - ry));     //x1
		cy=ry + (Sin(rangle) * (cx - rx) + Cos(rangle) * (cy - ry));     //y1
		endangle-=rangle;
		startangle-=rangle;
	}
	int fx=cx+(Cos(-(endangle+startangle)/2)*radius/2);
	int fy=cy+(Sin(-(endangle+startangle)/2)*radius/2);
	if (fx >= 0 && fy >= 0 && fx < bmp->Width && fy < bmp->Height && (Abs(startangle-endangle) > 2 || radius >20)) bmp->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, fill, opacity);
	else bmp->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, false, opacity);
}