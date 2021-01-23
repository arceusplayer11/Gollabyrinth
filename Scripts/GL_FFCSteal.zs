ffc script GetOtherScreenFFCData
{
	void run(int map, int screen, int ffcnum)
	{
		mapdata wtf = Game->LoadMapData(map, screen);
		this->Data = wtf->FFCData[ffcnum];
		this->X = wtf->FFCX[ffcnum];
		this->Y = wtf->FFCY[ffcnum];
	}
}