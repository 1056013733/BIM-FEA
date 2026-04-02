## ANSYS-only reproduction plan

This plan keeps the workflow fully inside ANSYS MAPDL after public data have been prepared.

### Goal

Reproduce one public benchmark end to end in ANSYS and produce enough outputs for a reviewer-facing validation package.

Primary benchmark:
- Thomsen and Wallace 1994, D3

Primary files:
- `generated/thom94d3_beam188.mac`
- `normalized/peer_thom94d3_force_displacement.csv`
- `generated/thom94d3_metadata.csv`

### Deliverables

1. Baseline ANSYS run
2. Mesh-sensitivity study
3. Material-parameter sensitivity study
4. Runtime/convergence summary
5. Plot-ready response tables
6. Reviewer-facing figure/table package

### Step 1. Baseline model

Use:
- `generated/thom94d3_beam188.mac`

Check before running:
- units are `mm-kN-MPa`
- section is `152.4 x 152.4 mm`
- member length is `596.9 mm`
- axial load is `331 kN`
- top-node cyclic displacement history is loaded from the public benchmark history

Run command:
```powershell
powershell -ExecutionPolicy Bypass -File C:\wys\tmshiyan\public_reproduction\scripts\run_thom94d3_ansys.ps1
```

Expected outputs:
- `generated/thom94d3_run/thom94d3.out`
- `generated/thom94d3_run/thom94d3.err`

### Step 2. Mesh sensitivity

Use three target element sizes:
- coarse: `50 mm`
- medium: `30 mm`
- fine: `25 mm`

Generate cases:
```powershell
powershell -ExecutionPolicy Bypass -File C:\wys\tmshiyan\public_reproduction\scripts\generate_thom94d3_mesh_cases.ps1
```

Run cases:
```powershell
powershell -ExecutionPolicy Bypass -File C:\wys\tmshiyan\public_reproduction\scripts\run_thom94d3_mesh_cases.ps1
```

Summarize cases:
```powershell
powershell -ExecutionPolicy Bypass -File C:\wys\tmshiyan\public_reproduction\scripts\extract_thom94d3_mesh_summary.ps1
```

Final tables:
- `generated/thom94d3_mesh_summary.csv`
- `generated/thom94d3_mesh_summary_detailed.csv`

### Step 3. Material-parameter sensitivity

Parameters to vary:
- `fc_mpa`
- `E`
- `fy`

Variation levels:
- `-20%`
- `-10%`
- baseline
- `+10%`
- `+20%`

Run order:
1. Generate parameterized APDL macros
2. Run each macro in MAPDL batch mode
3. Extract runtime and final-step summaries
4. Compare peak load and stiffness proxies

Output folder:
- `generated/param_sensitivity`

### Step 4. Runtime and convergence summary

For each run, collect:
- number of elements
- number of nodes
- warning count
- error count
- CP time
- elapsed time
- final load step

Store in:
- `generated/*.csv`

### Step 5. Plot-ready data

Extract:
- public displacement history
- ANSYS reaction/displacement history
- summary metrics by run case

Output folder:
- `generated/plot_data`

### Step 6. Reviewer-facing package

Prepare:
1. Force-displacement comparison plot
2. Mesh-sensitivity plot
3. Parameter-sensitivity plot
4. Runtime summary table
5. Short methods note describing:
   - element type
   - section dimensions
   - loading method
   - convergence settings
   - mesh sizes
   - parameter ranges

### Scope boundary

This ANSYS-only plan is sufficient for:
- public benchmark reproduction
- mesh sensitivity
- parameter sensitivity
- runtime reporting

This plan alone is not sufficient for strong claims about:
- crack initiation maps
- neutral-axis migration
- detailed load redistribution
- complete operator-variability elimination

Those require a richer constitutive model and possibly a more detailed section or solid model.
