/*start Tango Style args
const int TANGO_STYLE_BACKDROP_TYPE          = 0;
const int TANGO_STYLE_BACKDROP_DATA          = 1; // Complex only
const int TANGO_STYLE_BACKDROP_COLOR         = 1; // Color only
const int TANGO_STYLE_BACKDROP_TILE          = 1; // Frame and tile only
const int TANGO_STYLE_BACKDROP_COMBO         = 1; // Frame and combo only
const int TANGO_STYLE_BACKDROP_CSET          = 2; // Frame, tile, and combo only
const int TANGO_STYLE_BACKDROP_WIDTH         = 3; // Image and color only
const int TANGO_STYLE_BACKDROP_HEIGHT        = 4; // Image and color only
const int TANGO_STYLE_TEXT_FONT              = 5;
const int TANGO_STYLE_TEXT_X                 = 6;
const int TANGO_STYLE_TEXT_Y                 = 7;
const int TANGO_STYLE_TEXT_WIDTH             = 8;
const int TANGO_STYLE_TEXT_HEIGHT            = 9;
const int TANGO_STYLE_TEXT_CSET              = 10; // Default
const int TANGO_STYLE_TEXT_COLOR             = 11; // Default (built-in fonts)
const int TANGO_STYLE_TEXT_SPEED             = 12; // Default
const int TANGO_STYLE_TEXT_SFX               = 13; // Default
const int TANGO_STYLE_TEXT_END_SFX           = 14;
const int TANGO_STYLE_MENU_CHOICE_INDENT     = 15;
const int TANGO_STYLE_MENU_CURSOR_COMBO      = 16;
const int TANGO_STYLE_MENU_CURSOR_CSET       = 17;
const int TANGO_STYLE_MENU_CURSOR_WIDTH      = 18;
const int TANGO_STYLE_MENU_CURSOR_HEIGHT     = 19;
const int TANGO_STYLE_MENU_CURSOR_MOVE_SFX   = 20;
const int TANGO_STYLE_MENU_SELECT_SFX        = 21;
const int TANGO_STYLE_MENU_CANCEL_SFX        = 22;
const int TANGO_STYLE_MENU_SCROLL_UP_COMBO   = 23;
const int TANGO_STYLE_MENU_SCROLL_UP_CSET    = 24;
const int TANGO_STYLE_MENU_SCROLL_UP_X       = 25;
const int TANGO_STYLE_MENU_SCROLL_UP_Y       = 26;
const int TANGO_STYLE_MENU_SCROLL_DOWN_COMBO = 27;
const int TANGO_STYLE_MENU_SCROLL_DOWN_CSET  = 28;
const int TANGO_STYLE_MENU_SCROLL_DOWN_X     = 29;
const int TANGO_STYLE_MENU_SCROLL_DOWN_Y     = 30;
const int TANGO_STYLE_MORE_COMBO             = 31;
const int TANGO_STYLE_MORE_CSET              = 32;
const int TANGO_STYLE_MORE_X                 = 33;
const int TANGO_STYLE_MORE_Y                 = 34;
const int TANGO_STYLE_FLAGS                  = 35;
const int TANGO_STYLE_ALT_CSET_1             = 36;
const int TANGO_STYLE_ALT_CSET_2             = 37;
const int TANGO_STYLE_ALT_CSET_3             = 38;
const int TANGO_STYLE_ALT_CSET_4             = 39;
const int TANGO_STYLE_ALT_COLOR_1            = 40;
const int TANGO_STYLE_ALT_COLOR_2            = 41;
const int TANGO_STYLE_ALT_COLOR_3            = 42;
const int TANGO_STYLE_ALT_COLOR_4            = 43;
const int TANGO_STYLE_ALT_OFFSET_1           = 44;
const int TANGO_STYLE_ALT_OFFSET_2           = 45;
const int TANGO_STYLE_ALT_OFFSET_3           = 46;
const int TANGO_STYLE_ALT_OFFSET_4           = 47;
const int __TANGO_SIZEOF_STYLE               = 48;
end Tango Style args*/



DEFINE STYLE_SELECTEDITEM = 4;
//start selected item style
//
CONFIG TANGO_ITMSEL_TEXT_WIDTH = 198;
CONFIG TANGO_ITMSEL_TEXT_HEIGHT = 42;
CONFIG TANGO_ITMSEL_TEXT_CSET = 0;
CONFIG TANGO_ITMSEL_TEXT_COLOUR = C_WHITE;
CONFIG TANGO_ITMSEL_TEXT_SPEED = 0;
CONFIG TANGO_ITMSEL_TEXT_SFX = SFX_MSG;
CONFIG TANGO_ITMSEL_ALT_CSET_1 = 0;
CONFIG TANGO_ITMSEL_ALT_COLOUR_1 = 7;

// End settings

// Use this function to display a ZScript string (int[]).
// The return value will be the ID of the slot used or
// TANGO_INVALID if no text slot was available.
int ShowItemString(int str, int x, int y)
{
	//Clear the textbox slot regardless
	int slot=TANGO_SLOT_TEXTBOX;
	__Tango_ClearSlotBitmap(slot);
	Tango_ClearSlot(slot);
	Tango_LoadString(slot, str);
	Tango_SetSlotStyle(slot, STYLE_SELECTEDITEM);
	Tango_SetSlotPosition(slot, x, y);
	Tango_ActivateSlot(slot);
	
	return slot;
}

// Use this function to display a ZC message (Quest->Strings).
// The return value will be the ID of the slot used or
// TANGO_INVALID if no text slot was available.
int ShowMessage(int msg, int x, int y)
{
	//Clear the textbox slot regardless
	int slot=TANGO_SLOT_TEXTBOX;
	Tango_ClearSlot(slot);
	Tango_LoadMessage(slot, msg);
	Tango_SetSlotStyle(slot, STYLE_SELECTEDITEM);
	Tango_SetSlotPosition(slot, x, y);
	Tango_ActivateSlot(slot);
	
	return slot;
}

//Sets up the selected item style
void SetUpItmSelStyle()
{
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_FONT, TANGO_FONT_LTTP_SMALL);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_WIDTH, TANGO_ITMSEL_TEXT_WIDTH);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_HEIGHT, TANGO_ITMSEL_TEXT_HEIGHT);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_CSET, TANGO_ITMSEL_TEXT_CSET);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_COLOR, TANGO_ITMSEL_TEXT_COLOUR);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_SPEED, TANGO_ITMSEL_TEXT_SPEED);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_TEXT_SFX, TANGO_ITMSEL_TEXT_SFX);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_FLAGS, (TANGO_FLAG_INSTANTANEOUS | TANGO_FLAG_PERSISTENT | TANGO_FLAG_ENABLE_SPEEDUP));
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_ALT_CSET_1, TANGO_ITMSEL_ALT_CSET_1);
	Tango_SetStyleAttribute(STYLE_SELECTEDITEM, TANGO_STYLE_ALT_COLOR_1, TANGO_ITMSEL_ALT_COLOUR_1);
}
//end selected item style