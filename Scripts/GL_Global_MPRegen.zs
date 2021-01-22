/*
Yo, HeroOfFire or whoever is looking at this;
Feel free to tweak the math if you want, 
Cause I'm not good at math
*/

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