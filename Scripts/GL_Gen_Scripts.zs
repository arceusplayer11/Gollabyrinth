//Written by Dimi
//Simply gives the weapon a lifespan, potentially drawing its tile to a different layer or keeping it persistent ~ Orithan
lweapon script LWeaponLifespan
{
	void run(int lifespan, int layer, int persistent)
	{
		unless (layer || persistent) //Neither layer or persistent is set, weapon does nothing until its lifespan times out. ~ Orithan
		{
			Waitframes(lifespan);
			this->DeadState = WDS_DEAD;
		}
		else
		{
			for (int i = 0; i < lifespan; ++i)
			{
				if (layer) Screen->FastTile(layer, this->X, this->Y, this->Tile, this->CSet, (this->DrawStyle == DS_PHANTOM ? OP_TRANS : OP_OPAQUE));
				if (persistent) this->DeadState = -1; //Keep weapon alive after hitting enemy. ~ Orithan
				Waitframe();
			}
			this->DeadState = WDS_DEAD;
		}
	}
}

//Dimi's SkillTree script.
//I'll eventually merge my SkillTree script with Dimi's ~ Orithan
ffc script DrawSkillTree
{
	void run(int ffcid)
	{
		ffc linkto = Screen->LoadFFC(ffcid);
		
		int rectwidth = 2;
		
		
		int xdif = linkto->X - this->X;
		int ydif = linkto->Y - this->Y;
		int startx = this->X + 8 - (rectwidth/2);
		int starty = this->Y + 8 - (rectwidth/2);
		int endx = linkto->X + 8 - (rectwidth/2);
		int endy = linkto->Y + 8 - (rectwidth/2);
		
		--rectwidth;
		
		while(true)
		{
			xdif = linkto->X - this->X;
			ydif = linkto->Y - this->Y;
			startx = this->X + 8 - ((1+rectwidth)/2);
			starty = this->Y + 8 - ((1+rectwidth)/2);
			endx = linkto->X + 8 - ((1+rectwidth)/2);
			endy = linkto->Y + 8 - ((1+rectwidth)/2);
			Screen->Rectangle(1, startx, starty, startx+rectwidth, starty+(ydif/2)+(ydif<0?rectwidth:0), C_WHITE, 1, 0, 0, 0, true, OP_OPAQUE);
			SafeArc2(1, (xdif<0?startx:startx+rectwidth), starty+(ydif/2)+(ydif<0?rectwidth:0), rectwidth, (ydif<0?270:90), (xdif<0?180:0), C_WHITE, 1, 0, 0, 0, true, true, OP_OPAQUE);
			if (xdif<0)
			{
				Screen->Rectangle(1, startx, starty+(ydif/2)+rectwidth, endx+rectwidth, starty+(ydif/2), C_WHITE, 1, 0, 0, 0, true, OP_OPAQUE);
				SafeArc2(1, endx+rectwidth, starty+(ydif/2)+(ydif<0?0:rectwidth), rectwidth, 180, (ydif<0?90:270), C_WHITE, 1, 0, 0, 0, true, true, OP_OPAQUE);
			}
			else
			{
				Screen->Rectangle(1, startx+rectwidth, starty+(ydif/2)+rectwidth, endx, starty+(ydif/2), C_WHITE, 1, 0, 0, 0, true, OP_OPAQUE);
				SafeArc2(1, endx, starty+(ydif/2)+(ydif<0?0:rectwidth), rectwidth, (ydif<0?90:270), 0, C_WHITE, 1, 0, 0, 0, true, true, OP_OPAQUE);
			}
			Screen->Rectangle(1, endx, starty+(ydif/2)+(ydif<0?0:rectwidth), endx+rectwidth, endy, C_WHITE, 1, 0, 0, 0, true, OP_OPAQUE);
			Waitframe();
		}
	}
}