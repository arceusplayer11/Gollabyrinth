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