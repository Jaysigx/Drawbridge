Config                  = Config or {}
Config.Bridge1Position  = vector3(353.3317, -2315.838, 6.9134) -- these are static positions, and should not really 
Config.Bridge2Position  = vector3(219.5085, -2319.442, 5.0135) -- be changed unless you physically move the bridges.

Config.Commands         = true       -- allow commands to be used to control the bridge, exports are availible no matter what
Config.AutomaticTrafficZones = true  -- will automatically handle stopping traffic at red lights at the car bridge. 
                                     -- disable for automatic scenarios, running the full bridge sequence or manual control.
Config.ProximityTrafficLights = true -- automatically enable proximity based state-resetting of traffic lights when close to a bridge.
