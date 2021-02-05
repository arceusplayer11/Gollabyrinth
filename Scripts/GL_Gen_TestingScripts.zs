//Changes the parameter of a ring item at the press of the A or B button. Specifically for testing and may be removed at any time without warning.
ffc script RingChanger
{
	void run(int itm, int dmgtake, int spritepal, int ltm, int dmgtake2, int spritepal2, int ltm2)
	{
		using namespace Character;
		itemdata itmdat = Game->LoadItemData(itm);
		if(itmdat->Family != IC_RING || !Hero->Item[itm]) //Quick check for item validity - Item is valid if it is a Ring item the player holds
			Quit();
		while(true)
		{
			if(Input->Press[CB_A])
			{
				AssignCharacter(Etherchar);
				Audio->PlaySound(SFX_SECRET);
			}
			else if(Input->Press[CB_B])
			{
				AssignCharacter(Helena);
				Audio->PlaySound(SFX_SECRET);
			}
			Waitframe();
		}
	}
}