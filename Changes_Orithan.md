# GOLLABYRINTH - CHANGES MADE BY ORITHAN


### Commit #2. ZC Version: 2.55 Alpha 85+. Feburary 5th 2021.

- The player can now be assigned a character. This can also allow them to change characters. Also added the Coin item and its respective counter.
- BUG WORKWAROUND: Raised the level of the Palette Ring item and added a new lower level Palette Ring item in its place. This exists solely to get around the ZC bug where changing the Sprite Palette of the highest level Ring item the player has does not update the player's palette and will be removed when this bug is fixed.
- Added a file for testing scripts: `GL_Gen_TestingScripts.zs`. Stick stuff that's clearly meant to be for testing purposes here.
- Documented what every `G[]` var is used for.
- Added comments to the subscreen script.
- Revamped the magic regen system to be more robust.
- Added the four core base stats, `G_ATTACK`, `G_DEFENSE`, `G_SPEED`, `G_MAGIC` to the `G[]` array. Currently only `G_MAGIC` is functional as a result of the the magic system revamp.
- Added Global Script Init, which currently sets up the four core base stats to their default values.
- Added support for setting up characters through adding `GL_Global_Characters.zs`. Currently does nothing as of now.
- Added basic drawing functionality for the skill tree. Look in the newly added `GL_Global_SkillTree.zs` for details. Currently uses Map 1 Screen 71 for its draw data and currently does nothing but draw a black rectangle if you press the button to view the skill tree. This will change as more gets added to it.
- Added Helena's graphics. Her tiles are directly below that of Ether's character. Her Extra Sprite Palette is 9.
- Changed the first colour ramp in CSet 5 to a brown.