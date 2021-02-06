namespace Character
{
	//Pointers for each upgrade var
	enum Upgrade
	{
		UPGRADE_ID,		//Int - Upgrade X ID for the character
		UPGRADE_MISC, 	//Untyped - Upgrade X ID's misc var for the character
		UPGRADE_PRICE,	//Int - Upgrade X coin cost
		UPGRADE_BROUGHT,	//Bool - Has upgrade X been brought?
		UPGRADE_END		//Number of upgrade vars per upgrade
	};
	enum
	{
		CHARACTER_TILEOFF,			//Int - The LTM the character uses for their tiles
		CHARACTER_PALETTE,			//Int - Extra Sprite Palette the character uses.
		CHARACTER_SIG1,				//Int - ID of character's first signature
		CHARACTER_SIG2,				//Int - ID of character's second signature or passive
		CHARACTER_ATTACK,			//Float - Initial damage multiplier. Ignored if left at 0
		CHARACTER_DEFENSE,			//Float - Initial defense multiplier. Ignored if left at 0
		CHARACTER_SPEED,			//Float - Initial speed multiplier. Ignored if left at 0
		CHARACTER_MAGIC,			//Float - Initial magic regen multiplier. Ignored if left at 0.
		//The upgrade vars should come after anything else in the enum list.
		CHARACTER_UPGRADE,			//Int - Upgrade X for the character
		CHARACTER_END = CHARACTER_UPGRADE+32*UPGRADE_END //Cap off the character arrays at a number large enough to contain the baseline statistics for each character plus all of the baggage their 32 upgrade slots come with
	};
	//Formula for acquiring 
	//List of character IDs
	enum CharIDs
	{
		CHAR_LUANJA,	//Ether's character
		CHAR_HELENA,	//Orithan's character
		CHAR_END
	};
	//Signature list
	enum Signature
	{
		S_NONE,
		S_RAPIER,
		S_MUSKET,
		S_END
	};
	untyped Luanja[CHARACTER_END];		//Ether's character
	untyped Helena[CHARACTER_END];		//Helena
	untyped CharacterPointers[CHAR_END];	//Contains character array pointers.
	//Returns the correct index to read in a given upgrade var in a character array. This is mainly here to compress the math involved into a function call.
	int UpgVar(int upgradeid, int upgradevar)
	{
		using namespace Character;
		if(upgradevar >= 0 && upgradevar < UPGRADE_END && upgradeid >= 0 && upgradevar < 32)
			return CHARACTER_UPGRADE+upgradevar+upgradeid*UPGRADE_END;
		return -1; //ERROR. Either arg passed is illegal
	}
	void LuanjaInit() 					//Initializes/refreshes Luanja's character vars.
	{
		using namespace Character;
		Luanja[CHARACTER_TILEOFF] = 0;
		Luanja[CHARACTER_PALETTE] = 8;
	}
	void HelenaInit() 					//Initializes/refreshes Helena's character vars.
	{
		using namespace Character;
		Helena[CHARACTER_TILEOFF] = 40;
		Helena[CHARACTER_PALETTE] = 9;
		Helena[CHARACTER_SIG1] = S_RAPIER;					//Rapier
		Helena[CHARACTER_SIG2] = S_MUSKET;					//Musket
		Helena[CHARACTER_MAGIC] = 0.75;						//-25% Magic Regen
		Helena[UpgVar(0, UPGRADE_ID)] = SKILL_SPEEDUP;		//Initial upgrade - Speed
		Helena[UpgVar(0, UPGRADE_MISC)] = 0.15;				//Only need a small upgrade at this point.
		Helena[UpgVar(0, UPGRADE_PRICE)] = 10;				//Also only needs a small amount of coins.
	}
	//Assigns the character pointers to its array. Stick your character arrays here, making sure to reference their ID in the enum. Is called in the Global Init script
	void AssignCharPointers()
	{
		CharacterPointers[CHAR_LUANJA] = Luanja;
		CharacterPointers[CHAR_HELENA] = Helena;
	}
	//Changes the character. Do note that modifying HMISC_CHARID by itself does nothing - the game needs to update the player's stats, skills, etc. first
	void ChangeCharacter(int charid)
	{
		using namespace Character;
		Hero->Misc[HMISC_CHARID] = charid;
		AssignCharacter(CharacterPointers[charid]);
	}
	//Supply an array that is the size of CHARACTER_END to use this function. I_RINGPALETTE also needs to be a Ring item.
	//This assigns the character the player is playing as.
	void AssignCharacter(untyped chararray)
	{
		using namespace Character;
		itemdata palring = Game->LoadItemData(I_RINGPALETTE);
		if(SizeOfArray(chararray) == CHARACTER_END && palring->Family == IC_RING)
		{
			palring->Modifier = chararray[CHARACTER_TILEOFF];
			//Sanity checks the palette selection
			if(chararray[CHARACTER_PALETTE] >= 0 && chararray[CHARACTER_PALETTE] <= 29) //Assign Palette
				ChangePalette(palring, chararray[CHARACTER_PALETTE]);
			AssignData(chararray); //Assign stats (and remaining coins)
		}
	}
	//Assign the character's data and also number of coins remaining
	void AssignData(untyped chararray)
	{
		//Assign base stats, defaulting if they do not have that base stat set.
		Hero->Misc[HMISC_ATTACK] = chararray[CHARACTER_ATTACK] > 0 ? BASESTAT_ATTACK*chararray[CHARACTER_ATTACK] : BASESTAT_ATTACK;
		Hero->Misc[HMISC_DEFENSE] = chararray[CHARACTER_DEFENSE] > 0 ? BASESTAT_DEFENSE*chararray[CHARACTER_DEFENSE] : BASESTAT_DEFENSE;
		Hero->Misc[HMISC_SPEED] = chararray[CHARACTER_SPEED] > 0 ? BASESTAT_SPEED*chararray[CHARACTER_SPEED] : BASESTAT_SPEED;
		Hero->Misc[HMISC_MAGIC] = chararray[CHARACTER_MAGIC] > 0 ? BASESTAT_MAGIC*chararray[CHARACTER_MAGIC] : BASESTAT_MAGIC;
		//Scan the coin upgrades
		int coins = Game->MCounter[CR_COINS];
		for(int ind = CHARACTER_UPGRADE; ind < CHARACTER_END; ind += UPGRADE_END)
		{
			if(chararray[ind+UPGRADE_BROUGHT]) //Upgrade is brought
			{
				coins -= chararray[ind+UPGRADE_PRICE]; //Deduct coins
				switch(chararray[ind+UPGRADE_ID])
				{
					//Same line braces used because these are simple statements and thus could benefit greatly from being compacted as opposed to being strewn across several lines each like it would be otherwise
					case SKILL_ATTACKUP: { Hero->Misc[HMISC_ATTACK] += chararray[ind+UPGRADE_MISC]; break; } //Attack upgrade.
					case SKILL_DEFENSEUP: { Hero->Misc[HMISC_DEFENSE] += chararray[ind+UPGRADE_MISC]; break; } //Defense upgrade.
					case SKILL_SPEEDUP: { Hero->Misc[HMISC_SPEED] += chararray[ind+UPGRADE_MISC]; break; } //Speed upgrade.
					case SKILL_MAGICREGEN: { Hero->Misc[HMISC_MAGIC] += chararray[ind+UPGRADE_MISC]; break; } //Magic upgrade.
				}
			}
		}
		//Take the total amount of coins the player should have with the amount they spent on the character
		Game->Counter[CR_COINS] = coins;
	}
	//Ensures that the player's palette is actually changed when requested. This will be removed when the bug that prevents their palette from being changed by just changing the sprite palette field is fixed.
	void ChangePalette(itemdata palring, int pal)
	{
		palring->Attributes[0] = pal;
		Hero->Item[I_RINGPALETTE0] = Hero->Item[I_RINGPALETTE0] ? false : true; //Ternary saves the day again
	}
}