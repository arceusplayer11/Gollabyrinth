itemdata script SnareTrapItem
{
	void run()
	{
		lweapon handler= Screen->CreateLWeapon(LW_SCRIPT10);
		handler->Script = Game->GetLWeaponScript("SnareTrap");
		handler->InitD[0] = this->Script;
	}
}

const int SPR_RETICLE = 109;
const int SPR_VINE1 = 107;
const int SPR_VINE2 = 108;

lweapon script SnareTrap
{
	void run(int itemid)
	{
		this->UseSprite(SPR_RETICLE);
		this->CollDetection = false;
		this->X = Hero->X;
		this->Y = Hero->Y;
		this->Damage = 2;
		this->Dir = 8;
		while (IsUsingItem(itemid))
		{
			if (Input->Button[CB_UP]) this->Y-=2;
			if (Input->Button[CB_DOWN]) this->Y+=2;
			if (Input->Button[CB_LEFT]) this->X-=2;
			if (Input->Button[CB_RIGHT]) this->X+=2;
			Hero->Action = LA_NONE;
			Hero->Action = LA_ATTACKING;
			Hero->Dir = DIR_DOWN;
			Hero->Stun = 8;
			Waitframe();
		}
		this->Extend = 3;
		this->UseSprite(SPR_VINE1);
		this->DrawXOffset = -8;
		this->DrawYOffset = -8;
		this->HitXOffset = -8;
		this->HitYOffset = -8;
		this->TileHeight = 2;
		this->TileWidth = 2;
		this->HitWidth = 32;
		this->HitHeight = 32;
		
		Waitframes(8);
		
		this->UseSprite(SPR_VINE2);
		this->DrawXOffset = -8;
		this->DrawYOffset = -8;
		this->HitXOffset = -8;
		this->HitYOffset = -8;
		this->TileHeight = 2;
		this->TileWidth = 2;
		this->HitWidth = 32;
		this->HitHeight = 32;
		this->CollDetection = true;
		
		for(int i = 0; i < 48; ++i)
		{
			this->DeadState = -1;
			Waitframe();
		}
		
		this->UseSprite(SPR_VINE1);
		this->DrawXOffset = -8;
		this->DrawYOffset = -8;
		this->HitXOffset = -8;
		this->HitYOffset = -8;
		this->TileHeight = 2;
		this->TileWidth = 2;
		this->HitWidth = 32;
		this->HitHeight = 32;
		
		Waitframes(8);
		
		this->DeadState = WDS_DEAD;					
		Quit();
	}
}