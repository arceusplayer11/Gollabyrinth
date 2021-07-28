# GOLLABYRINTH - CHANGES MADE BY ORITHAN

### Commit #5. ZC Version: 2.55 Alpha 85+. July 29th 2021.

- Skill tree draws are now operational. They only work with Luanja so far.
- Added Bitmap versions of Dimi's Safe Arc functions.
- Optimized the `DrawBoxScale()` function. Now it only requires the three corner args for its tile metadata, but it also asks you to set your horizontal and vertical box border tiles to the tiles right after it.
- Added a list of element definitions to the main file in preparation for a mechanic I am planning on setting up.
- Tweaked Nova, added a proper Magic cost to it and added CONFIGs for it.

### Commit #4. ZC Version: 2.55 Alpha 85+. July 27th 2021.

- Added `DrawLayerFix.zh` and put it into a dedicated header folder. This version is wrapped in the `DrawLayerFix` namespace in the unlikely event we end up getting other functions with the same identifier.
- The Plasma Spell, Nova, has been implemented. The SFX and explosion sprites are currently placeholder. I need to secure a source of either Metroid Prime 1's Plasma Beam charge and charge shot SFX or Metroid Prime 3's Nova Beam charge and charge shot SFX or something that feels similar to those. I also need a more "solar" explosion animation.
- Force disabled the `2.50 Divison Trunication` and `2.50 Boolean value of 0.0001` Compiler settings. The former being set to On was causing serious bugs with my code due to the way 2.50 division trunication worked.
- Added documentation for some of Dimi's scripts. I would very much appreciate if you comment your stuff so I don't have to come in, interpert what it is and then write the comments myself, Dimi.
- Reverted the change the `G_[Stat]` variables had. Now they read from the `G[]` Array again.

### Commit #3. ZC Version: 2.55 Alpha 85+. Feburary 7th 2021.

- Added a new box drawing function, `DrawBoxScale()`, to `GL_Gen_Functions`. This is a drawing function which uses scaling to draw text boxes, allowing for ones that grow or shrink and easily allowing for sub-tile increments. Look it up for more details.
- Moved the skill tree tiles to Page 160 and 161.
- Properly implemented character switching. Also improved the stat calculation formula. Currently needs testing on the coins
- Fixed the magic regen formula to account for it through the whole formula as opposed to affecting a single part of it.
- Moved the four base stats to `Hero->Misc[]`, prefixed with `HMISC_` instead of `G_`, and added a parameter for current character ID `HMISC_CHARID`.
- Forgot to mention this last commit: All `import` statements are replaced with `#include` statements. They do the same thing except make it easier for people working on the file to work on it if they put their scripts outside the ZC folder.

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