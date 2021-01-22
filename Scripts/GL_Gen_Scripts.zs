lweapon script LWeaponLifespan
{
	void run(int lifespan)
	{
		Waitframes(lifespan);
		this->DeadState = WDS_DEAD;
	}
}