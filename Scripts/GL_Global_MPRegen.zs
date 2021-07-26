/*
Yo, HeroOfFire or whoever is looking at this;
Feel free to tweak the math if you want, 
Cause I'm not good at math
Reworked by Orithan
*/

//Runs the regeneration system in the game. The lower MP you have, the faster you recharge.
void MagicRegen()
{
	G[G_MPREGEN] += (6 + 128/Hero->MaxMP*(Hero->MaxMP - Hero->MP)/(100/Hero->MaxMP*Hero->MP <= 25 ? 8 : 12))*G[G_MAGIC]; //Calculates magic that should be regend this frame. This formula could do with some further tweaking
	while (G[G_MPREGEN] > 768)
	{
		G[G_MPREGEN]-=256;
		if (Hero->MP < Hero->MaxMP) ++Hero->MP;
	}
}

//Prevents MP from recovering until after a set amount of time, which is tracked by the cooldown variable.
void MPCooldownTimer()
{
	if(G[G_MPCOOLDOWN] > 0)
		G[G_MPREGEN] = 0;
	G[G_MPCOOLDOWN] -= G[G_MPCOOLDOWN] > 0 ? 1 : 0; //Ternary statements are good for if you just need a simple conditional statement.
}

//Halts MP regen and waits a frame
void MPWaitframe()
{
	G[G_MPREGEN] = 0;
	Waitframe();
}

//Overloaded to grant it the option to also set the initial cooldown
void MPWaitframe(int cooldown)
{
	G[G_MPREGEN] = 0;
	G[G_MPCOOLDOWN] = cooldown;
	Waitframe();
}

//Halts MP regen and waits multiple frames
void MPWaitframes(int frames)
{
	for (int i = 0; i < frames; ++i) MPWaitframe();
}

//Overloaded to allow the option to also set the initial cooldown over multiple frames.
void MPWaitframes(int frames, int cooldown)
{
	for (int i = 0; i < frames; ++i) MPWaitframe(cooldown);
}

/*
Original functions by Dimi. Kept here as depreciated code in case we want to revert

void EmergencyRegen()
{
	G[G_MPREGEN] += (Hero->MaxMP - Hero->MP)/2;
	while (G[G_MPREGEN] > 768)
	{
		G[G_MPREGEN]-=256;
		if (Hero->MP < Hero->MaxMP) ++Hero->MP;
	}
}

void MPWaitframe()
{
	G[G_MPREGEN] = 0;
	Waitframe();
}

void MPWaitframes(int frames)
{
	for (int i = 0; i < frames; ++i) MPWaitframe();
}
*/