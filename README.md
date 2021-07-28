# Gollabyrinth
Yuurand-styled collab


This basically is a collaboration to make a yuurand-styled quest.


## FOR SCRIPTERS
For those scripting for Gollabyrinth, there are a set of rules scripts should follow

### Function calls.
The following things should be done through specific functions to ensure stability and cooperation with the quest's scripted systems.
- Any time you draw to Layers 2 or 3 on the screen call `DrawLayerFix::[function]` instead of `Screen->[function]`. `DrawLayerFix` works around issues where methods of drawing over/under sprites instead draw to a background layer if the flags for Layers 2 or 3 are set.
- Any time you wish to set damage to an attack made by the player, call `Character::GetAttackDamage([damage])` to ensure it respects the player's current Attack stat and potentially any boosts (eg. Power Boost, Strong Element). The only exception being if you want an attack to ignore any scripted modifiers.
