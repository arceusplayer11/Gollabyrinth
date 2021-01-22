const int ITEM_DUMMY = 255;

/*
Okay, so items. Items are handled via fake items.

On Tile Page 150 of the quest, there are a bunch of item icons. These are important, because they correspond 1 to 1 with the item assigned to either
the subscreen or the item buttons; that is the tile that will be drawn for that item. Tile 39001 is the base tile; item 0 (which doesn't exist) uses 39001 + 0,
item 24 would use tile 39025, etc.

As for item functions, we use item scripts for those, and they line up 1-1 with the item id. So item 1 will use item script 1, and so on. 
If there is a point where we need to use an item script for any purpose other than using an item (say, item pickup strings or etc), we need 
to avoid using that item id.

If at all possible, try to avoid running item scripts for more than one frame, there might be some issues otherwise.
*/

void ABLR_Handle()
{
	for (int inp = CB_UP; inp < CB_MAX; ++inp) 	//More than one button can be pressed at once
	{					   	//They are all independant of eachother
							//By having this for loop, I don't need to add code to every button
							//Because not only is that a pain to add content to,
							//And not only is that a pain to bugtest,
							//But it means that you can't accidentally forget to add code to one button
							//Having inconsistent behavior between A button being pressed and B button being pressed
		switch(inp)
		{
			case CB_A:
			case CB_B:
			case CB_L:
			case CB_R:
			{
				if (Input->Press[inp]) 	//and then I realize that I basically went on that giant rant for nothing because item scripts
				{
					int scriptid = G[G_BUTTON_A+(inp-CB_A)];
					if (scriptid)
					{
						itemdata itemdummy = Game->LoadItemData(ITEM_DUMMY);
						itemdummy->Script = scriptid;
						itemdummy->RunScript(2);
					}
				}
			}
			
			default:
				break;
		}
	}
}