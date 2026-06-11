# Converted raw environments

These files are AMSwarm-compatible versions of the YAML files in `env_raw`.

Use one with:

```bash
AMSWARM_CONFIG=params/env_raw_converted/config_am_swarm_env_2.yaml rosrun amswarm swarm_am_nav
```

The simulator still defaults to `params/config_am_swarm.yaml` when `AMSWARM_CONFIG`
is not set.

Conversion notes:

- raw values are interpreted as meters, with no coordinate or radius scaling
- `maximum_velocity` -> `vel_max`
- `maximum_acceleration` -> `acc_max`
- `goal_torlance_distance` -> `dist_stop`
- `initial_positions` -> `init_drone`
- `goal_positions` -> `goal_drone`
- `obstacle_positions` -> `pos_static_obs`
- each raw circular obstacle becomes `dim_static_obs: [obstacle_radius, obstacle_radius, 10.0]`
- raw obstacle z positions are preserved as cylinder center positions
- `world` is set to `2` because the raw environments are planar
- `use_thrust_values` is set to `false` so the raw `maximum_acceleration`
  value is actually used by AMSwarm
- room bounds are widened to include the 2.5 m start/goal circle and z = 0
