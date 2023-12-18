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
/bridge: Spawns the bridge
/bridgeUp 1-2 Z.height
          -for example /bridgeUp 1 20
/bridgeDown 1-2 Z.height
          -for example /bridgeDown 1 20
/gateall up/down    --incomplete
/gate 1-4 up/down   --incomplete
```

Configuration
=================
Movement Speed: Adjust the speed of the drawbridge movement by modifying the bridgeMovementSpeed variable in client/cl_movebridge.lua.
Height Limits: Set the maximum and minimum allowed heights for the drawbridge by adjusting maxBridgeHeight and minBridgeHeight in client/cl_movebridge.lua.
briddge location at where they spawn is in config.lua

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
there is no transition for the gates and the rotation for 2 gates is broken

future roadmap:
=================
interact sound for bridge and interactable traffic gates.
transitions for gates. 
traffic will stop while bridge is not at inital position.
exports for most functions so server owners can enjoy.


License
=================
This script is open-sourced under the MIT License.
