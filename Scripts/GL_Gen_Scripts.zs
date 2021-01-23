lweapon script LWeaponLifespan
{
	void run(int lifespan, int layer)
	{
		if (layer <= 0)
		{
			Waitframes(lifespan);
			this->DeadState = WDS_DEAD;
		}
		else
		{
			for (int i = 0; i < lifespan; ++i)
			{
				Screen->FastTile(layer, this->X, this->Y, this->Tile, this->CSet, (this->DrawStyle == DS_PHANTOM ? OP_TRANS : OP_OPAQUE));
				Waitframe();
			}
			this->DeadState = WDS_DEAD;
		}
	}
}