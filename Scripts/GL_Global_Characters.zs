//This is written by Orithan.
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
		CHARACTER_UPGRADESCREEN,	//Int - Screen to read from for skill tree upgrades.
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
	void LuanjaInit() 					//Initializes/refreshes Luanja's character vars.
	{
		using namespace Character;
		Luanja[CHARACTER_TILEOFF] = 0;
		Luanja[CHARACTER_PALETTE] = 8;
		Luanja[CHARACTER_UPGRADESCREEN] = 0x71;
	}
	void HelenaInit() 					//Initializes/refreshes Helena's character vars.
	{
		using namespace Character;
		Helena[CHARACTER_TILEOFF] = 40;
		Helena[CHARACTER_PALETTE] = 9;
		Helena[CHARACTER_SIG1] = S_RAPIER;					//Rapier
		Helena[CHARACTER_SIG2] = S_MUSKET;					//Musket
		Helena[CHARACTER_MAGIC] = 75;						//-25% Magic Regen
		Helena[CHARACTER_UPGRADESCREEN] = 0x72;
		Helena[UpgVar(0, UPGRADE_ID)] = SKILL_SPEEDUP;	//Initial upgrade - Speed
		Helena[UpgVar(0, UPGRADE_MISC)] = 15;				//Only need a small upgrade at this point.
		Helena[UpgVar(0, UPGRADE_PRICE)] = 10;				//Also only needs a small amount of coins.
		Helena[UpgVar(1, UPGRADE_ID)] = SKILL_STRONGMETAL;
		Helena[UpgVar(1, UPGRADE_MISC)] = 33.4;				//+33% damage with Metal.
		Helena[UpgVar(1, UPGRADE_PRICE)] = 20;				//Fairly strong upgrade.
		Helena[UpgVar(2, UPGRADE_ID)] = SKILL_CHEAPTECH;
		Helena[UpgVar(2, UPGRADE_MISC)] = 25;				//3/4 MP Tech.
		Helena[UpgVar(2, UPGRADE_PRICE)] = 15;				//Basic upgrade, don't need a lot of coins.
		Helena[UpgVar(3, UPGRADE_ID)] = SKILL_SPECIAL;		//Duelist
		Helena[UpgVar(3, UPGRADE_PRICE)] = 40;				//Takes a big chunk of coins.
		Helena[UpgVar(4, UPGRADE_ID)] = SKILL_CHEAPMETAL;
		Helena[UpgVar(4, UPGRADE_MISC)] = 33.4;				//2/3 MP Metal.
		Helena[UpgVar(4, UPGRADE_PRICE)] = 15;				//Fairly strong upgrade.
		Helena[UpgVar(5, UPGRADE_ID)] = SKILL_STRONGTECH;
		Helena[UpgVar(5, UPGRADE_MISC)] = 25;				//+25% Damage with Tech.
		Helena[UpgVar(5, UPGRADE_PRICE)] = 20;				//Fairly strong upgrade.
		Helena[UpgVar(6, UPGRADE_ID)] = SKILL_SPEEDUP;
		Helena[UpgVar(6, UPGRADE_MISC)] = 20;				//+20% Speed.
		Helena[UpgVar(6, UPGRADE_PRICE)] = 25;				//Fairly strong upgrade.
		Helena[UpgVar(7, UPGRADE_ID)] = SKILL_ATTACKUP;
		Helena[UpgVar(7, UPGRADE_MISC)] = 25;				//+25% Attack.
		Helena[UpgVar(7, UPGRADE_PRICE)] = 30;				//Fairly strong upgrade.
	}
	//Assigns the character pointers to its array. Stick your character arrays here, making sure to reference their ID in the enum. Is called in the Global Init script
	void AssignCharPointers()
	{
		CharacterPointers[CHAR_LUANJA] = Luanja;
		CharacterPointers[CHAR_HELENA] = Helena;
	}
	//Returns the correct index to read in a given upgrade var in a character array. This is mainly here to compress the math involved into a function call.
	int UpgVar(int upgradeid, int upgradevar)
	{
		using namespace Character;
		if(upgradevar >= 0 && upgradevar < UPGRADE_END && upgradeid >= 0 && upgradevar < 32)
			return CHARACTER_UPGRADE+upgradevar+upgradeid*UPGRADE_END;
		return -1; //ERROR. Either arg passed is illegal
	}
	//!!USE WITH CAUTION!!
	//Returns the data array pointer for a given character. If it is not an array (eg. not set up) it returns -1 instead.
	//MAKE SURE THE POINTER IS SANITIZED BEFOREHAND AND TO ENSURE THE RETURNED ARRAY POINTER IS VALID AFTERWARDS.
	int ReturnCharacterArray(int character)
	{
		//Character array pointer set up and valid.
		if(IsValidArray(CharacterPointers[character]) && SizeOfArray(CharacterPointers[character]) == CHARACTER_END)
			return CharacterPointers[character];
		//Invalid or not set up character
		return -1;
	}
	//Returns what is stored within a specific index of a given character array.
	int GetCharArrayIndex(int character, int index)
	{
		using namespace Character;
		int chardat = ReturnCharacterArray(character);
		//Sanitization checking...
		if(IsValidArray(chardat) && SizeOfArray(chardat) == CHARACTER_END) //Array is of correct size, get the data.
			return chardat[index];
		//An error has occured, give an invalid result.
		return -1;
	}
	//Set a value within a character array.
	void SetCharArrayIndex(int character, int index, untyped value)
	{
		using namespace Character;
		int chardat = ReturnCharacterArray(character);
		//Sanitization checking...
		if(IsValidArray(chardat) && SizeOfArray(chardat) == CHARACTER_END) //Array is of correct size, get the data.
			chardat[index] = value;
	}
	//Changes the character. 
	void ChangeCharacter(int charid)
	{
		using namespace Character;
		G[G_CHARID] = charid;
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
			UpdateStats(chararray); //Assign stats (and remaining coins)
		}
	}
	//Assign the character's data and also number of coins remaining
	void UpdateStats(untyped chararray)
	{
		//Check for valid character array
		if(IsValidArray(chararray) && SizeOfArray(chararray) == CHARACTER_END)
		{
			//Assign base stats, defaulting if they do not have that base stat set.
			G[G_ATTACK] = chararray[CHARACTER_ATTACK] > 0 ? BASESTAT_ATTACK*chararray[CHARACTER_ATTACK]/100 : BASESTAT_ATTACK;
			G[G_DEFENSE] = chararray[CHARACTER_DEFENSE] > 0 ? BASESTAT_DEFENSE*chararray[CHARACTER_DEFENSE]/100 : BASESTAT_DEFENSE;
			G[G_SPEED] = chararray[CHARACTER_SPEED] > 0 ? BASESTAT_SPEED*chararray[CHARACTER_SPEED]/100 : BASESTAT_SPEED;
			G[G_MAGIC] = chararray[CHARACTER_MAGIC] > 0 ? BASESTAT_MAGIC*chararray[CHARACTER_MAGIC]/100 : BASESTAT_MAGIC;
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
						case SKILL_ATTACKUP: { G[G_ATTACK] += chararray[ind+UPGRADE_MISC]; break; } //Attack upgrade.
						case SKILL_DEFENSEUP: { G[G_DEFENSE] += chararray[ind+UPGRADE_MISC]; break; } //Defense upgrade.
						case SKILL_SPEEDUP: { G[G_SPEED] += chararray[ind+UPGRADE_MISC]; break; } //Speed upgrade.
						case SKILL_MAGICREGEN: { G[G_MAGIC] += chararray[ind+UPGRADE_MISC]; break; } //Magic upgrade.
					}
				}
			}
			//Take the total amount of coins the player should have with the amount they spent on the character
			Game->Counter[CR_COINS] = coins;
		}
		else
		{
			TraceNL(); TraceS("ERROR: Invalid character array passed.");
		}
	}
	//Ensures that the player's palette is actually changed when requested. This will be removed when the bug that prevents their palette from being changed by just changing the sprite palette field is fixed.
	void ChangePalette(itemdata palring, int pal)
	{
		palring->Attributes[0] = pal;
		Hero->Item[I_RINGPALETTE0] = Hero->Item[I_RINGPALETTE0] ? false : true; //Ternary saves the day again
	}
	//Gets the secondary upgrade icon of an upgrade skill. Returns 0 if there is none associated with that particuar upgrade skill
	int GetUpgradeIcon(int id)
	{
		switch(id)
		{
			case SKILL_STRONGSPECTRAL:
			case SKILL_STRONGNATURE:
			case SKILL_STRONGWIND:
			case SKILL_STRONGICE:
			case SKILL_STRONGFIRE:
			case SKILL_STRONGNOVA:
			case SKILL_STRONGTECH:
			case SKILL_STRONGMETAL:
			case SKILL_STRONGASTRAL:
				return TILE_UPGRADE_DAMAGE;

			case SKILL_CHEAPSPECTRAL:
			case SKILL_CHEAPNATURE:
			case SKILL_CHEAPWIND:
			case SKILL_CHEAPICE:
			case SKILL_CHEAPFIRE:
			case SKILL_CHEAPNOVA:
			case SKILL_CHEAPTECH:
			case SKILL_CHEAPMETAL:
			case SKILL_CHEAPASTRAL:
				return TILE_UPGRADE_MAGIC;

			default:
				return 0;
		}
	}
	//Returns the amount of damage an attack would do to an enemy before their modifiers come into play.
	float GetAttackDamage(float damage, int element)
	{
		float multi = 1;
		//Check for elemental bonuses.
		switch(element)
		{
			case ELEMENT_SPECTRAL:
			{
				multi *= GetMultiBonus(SKILL_STRONGSPECTRAL);
				break;
			}
			case ELEMENT_NATURE:
			{
				multi *= GetMultiBonus(SKILL_STRONGNATURE);
				break;
			}
			case ELEMENT_WIND:
			{
				multi *= GetMultiBonus(SKILL_STRONGWIND);
				break;
			}
			case ELEMENT_ICE:
			{
				multi *= GetMultiBonus(SKILL_STRONGICE);
				break;
			}
			case ELEMENT_FIRE:
			{
				multi *= GetMultiBonus(SKILL_STRONGFIRE);
				break;
			}
			case ELEMENT_NOVA:
			{
				multi *= GetMultiBonus(SKILL_STRONGNOVA);
				break;
			}
			case ELEMENT_TECHNOLOGY:
			{
				multi *= GetMultiBonus(SKILL_STRONGTECH);
				break;
			}
			case ELEMENT_METAL:
			{
				multi *= GetMultiBonus(SKILL_STRONGMETAL);
				break;
			}
			case ELEMENT_ASTRAL:
			{
				multi *= GetMultiBonus(SKILL_STRONGASTRAL);
				break;
			}
		}
		return damage*(G[G_ATTACK]/100)*multi;
	}
	//Returns the amount of damage an attack would do to an enemy before their modifiers come into play.
	float GetMagicCost(float cost, int element)
	{
		float multi = 1;
		//Check for elemental bonuses.
		switch(element)
		{
			case ELEMENT_SPECTRAL:
			{
				multi -= GetMultiBonus(SKILL_CHEAPSPECTRAL)-1;
				break;
			}
			case ELEMENT_NATURE:
			{
				multi -= GetMultiBonus(SKILL_CHEAPNATURE)-1;
				break;
			}
			case ELEMENT_WIND:
			{
				multi -= GetMultiBonus(SKILL_CHEAPWIND)-1;
				break;
			}
			case ELEMENT_ICE:
			{
				multi -= GetMultiBonus(SKILL_CHEAPICE)-1;
				break;
			}
			case ELEMENT_FIRE:
			{
				multi -= GetMultiBonus(SKILL_CHEAPFIRE)-1;
				break;
			}
			case ELEMENT_NOVA:
			{
				multi -= GetMultiBonus(SKILL_CHEAPNOVA)-1;
				break;
			}
			case ELEMENT_TECHNOLOGY:
			{
				multi -= GetMultiBonus(SKILL_CHEAPTECH)-1;
				break;
			}
			case ELEMENT_METAL:
			{
				multi -= GetMultiBonus(SKILL_CHEAPMETAL)-1;
				break;
			}
			case ELEMENT_ASTRAL:
			{
				multi -= GetMultiBonus(SKILL_CHEAPASTRAL)-1;
				break;
			}
		}
		return Max(cost*multi, 0);
	}
	//Gets the current multiplier bonus to a specified element. This is designed to work with the Strong and Cheap [element] bonuses.
	float GetMultiBonus(int skill)
	{
		float multi = 100;
		untyped chardat = ReturnCharacterArray(G[G_CHARID]);
		if(IsValidArray(chardat) && SizeOfArray(chardat) == CHARACTER_END)
		{
			//Cycle through the upgrade bonuses and find out if any of the specified upgrade have been brought.
			for(int ind = CHARACTER_UPGRADE; ind < CHARACTER_END; ind += UPGRADE_END)
			{
				if(chardat[ind+UPGRADE_ID] == skill && chardat[ind+UPGRADE_BROUGHT])
					multi += chardat[ind+UPGRADE_MISC]; //Increase the multiplier.
			}
		}
		return multi/100;
	}
}