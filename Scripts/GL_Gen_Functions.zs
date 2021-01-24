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