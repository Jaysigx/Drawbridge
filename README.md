Drawbridge Script
=================
This script allows for the dynamic control and movement of drawbridges in Fivem, providing a way to raise or lower it using in-game commands.

Features
=================
Raise and Lower Commands: Control the drawbridge height using /raiseBridge and /lowerBridge commands.
Dynamic Movement: Smoothly raises or lowers the drawbridge to the desired height.
Configurability: Easily adjust parameters such as movement speed and height limits.

Usage
=================
Ensure you have the necessary dependencies and configurations set up.
Add the script files to your FiveM server's resources folder.
andd just ensure resource name

Commands
=================
```
/bridgelights 0-3                    
          Green = 0,
          Red = 1,
          Yellow = 2,
          Reset = 3

/bridgeUp 1-2 Z.height
          -for example /bridgeUp 1 20

/bridgeDown 1-2 Z.height
          -for example /bridgeDown 1 20

/gateall up/down    --incomplete

```

Configuration
=================
- Movement Speed: Adjust the speed of the drawbridge movement by modifying the bridgeMovementSpeed variable in client/cl_movebridge.lua.
- Height Limits: Set the maximum and minimum allowed heights for the drawbridge by adjusting maxBridgeHeight and minBridgeHeight in client/cl_movebridge.lua.
- briddge location at where they spawn is in config.lua
- toggle commands on or off if you only want to use exports

Server Integration
=================
For server owners:

1.Place the server.lua in your server's resources folder.

2.Ensure proper validation and permission logic for bridge adjustments within the server.lua script.


Contributing
=================
Feel free to fork this repository, make changes, and submit pull requests. Contributions are welcome!

Current  Issues
=================
```
- there is no transition for the gates and the rotation for 2 gates is broken
- Traffic does not stop when traffic lights changed to red (state 1)
```


License
=================
This script is open-sourced under the MIT License.

try the updated code in your environment, 

**Version 1.1**
=================
```
- think i fixed the syncing
- added exports
- added option in config to enable and disable commands
- added traffic lights, they will be at green at all time unless you do /bridgelights 0-3 
      Green = 0,
      Red = 1,
      Yellow = 2,
      Reset = 3
```
**how to use exports**
=================
```
-- Move the bridge up by calling the 'MoveBridgeUp' export
exports['bridgeControl']:MoveBridgeUp(1, 20)

-- Move the bridge down by using the 'MoveBridgeDown' export
exports['bridgeControl']:MoveBridgeDown(1, 20)

-- Toggle bridge lights on or off with the 'bridgelights' export
exports['bridgeControl']:bridgelights(1) -- Turns on the lights
exports['bridgeControl']:bridgelights(0) -- Turns off the lights
```
=================

again thank you everyone for support along the way, if you find any issues and have a fix, please make a pull request
love u guys


credits [PNWParksFan & Smallo](https://www.gta5-mods.com/maps/draw-bridge-map-script) for the bridge models
