**Car Drawbridge Script**
This script allows for the dynamic control and movement of a drawbridge in the game world, providing a way to raise or lower it using in-game commands.

**Features**
Raise and Lower Commands: Control the drawbridge height using /raiseBridge and /lowerBridge commands.
Dynamic Movement: Smoothly raises or lowers the drawbridge to the desired height.
Configurability: Easily adjust parameters such as movement speed and height limits.

**Usage**
Ensure you have the necessary dependencies and configurations set up.
Add the script files to your FiveM server's resources folder.
Start the script in your server.cfg file: ensure car_drawbridge.

**Commands**
/raiseBridge: Raises the drawbridge by 10 units.
/lowerBridge: Lowers the drawbridge by 10 units.

**Configuration**
Movement Speed: Adjust the speed of the drawbridge movement by modifying the bridgeMovementSpeed variable in client.lua.
Height Limits: Set the maximum and minimum allowed heights for the drawbridge by adjusting maxBridgeHeight and minBridgeHeight in client.lua.

**Server Integration**
For server owners:

1.Place the server.lua in your server's resources folder.
2.Ensure proper validation and permission logic for bridge adjustments within the server.lua script.
3.Sync the bridge height changes to all clients using the bridge:syncBridgeHeight event.

**Contributing**
Feel free to fork this repository, make changes, and submit pull requests. Contributions are welcome!

**License**
This script is open-sourced under the MIT License.
