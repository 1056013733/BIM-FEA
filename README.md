## Public reproduction package

This folder collects public benchmark datasets and helper scripts for reproducing the validation workflow described in the manuscript.

### Recommended starting datasets

1. PEER Structural Performance Database (SPD)
   - URL: https://peer.berkeley.edu/spd
   - Best fit for the manuscript's reinforced-concrete beam-column / column cyclic validation claims.
   - Includes geometry, material properties, reinforcement details, loading configuration, and digital force-displacement histories for hundreds of RC column tests.

2. Steel-Concrete Composite Column Database
   - URL: https://mark.denavit.me/Composite-Column-Database/
   - Best fit for the manuscript's composite-member benchmark extension.
   - Includes specimen metadata and experimental strength/deformation fields for steel-concrete composite columns and beam-columns.

3. Composite Beams Database
   - URL: https://zenodo.org/records/4423351
   - Useful as a supplemental composite benchmark source when a beam-scale validation case is acceptable.

4. Experimental data of dissipative embedded column base connections tested under cyclic lateral loading
   - URL: https://zenodo.org/records/4244684
   - Useful as a supplemental cyclic dataset with downloadable spreadsheets and rich response data.

### What is included here

- `data/datasets_manifest.json`: hand-curated public source manifest
- `scripts/download_public_datasets.py`: downloads files and records checksums
- `scripts/normalize_benchmark_data.py`: converts raw CSV/XLS/XLSX files into a normalized tabular form
- `scripts/build_ansys_input_template.py`: generates a small APDL macro from normalized metadata
- `templates/beam_column_template.mac`: APDL starter template for a beam-column benchmark

### Suggested workflow

1. Review `data/datasets_manifest.json` and keep only the datasets you will cite.
2. Run `download_public_datasets.py` to fetch the public files into `data/raw/`.
3. Run `normalize_benchmark_data.py` to create clean tables in `data/processed/`.
4. Edit specimen-specific fields as needed.
5. Run `build_ansys_input_template.py` to generate a specimen APDL file in `simulations/runs/`.
6. Run the generated APDL macro in ANSYS Mechanical APDL or adapt it for Workbench command snippets.

### Notes

- This package does not claim that every source has the exact same response metrics as the manuscript.
- PEER SPD is the strongest public match for cyclic RC validation.
- The composite databases are best used to support the "composite member" part of the study, especially if you need more open data breadth than one single cyclic dataset can provide.

### Data Source Declaration

This simulation experiment uses standard open benchmark datasets for cross-validation:
1. Primary Dataset: PEER Structural Performance Database (SPD)
2. Official Source: https://peer.berkeley.edu/spd
3. Current Case Study: Thomsen and Wallace 1994, Specimen D3
   (Includes geometry, reinforcement details, and force-displacement histories under cyclic loading for RC members)

### Automated Execution Notes

The Python script (`run_all_for_recording.py`) will automate the execution of the entire experimental workflow.
All processes, inputs, and outputs will be explicitly displayed in the console. The script will pause before each major stage to allow you to control the pace of your screen recording.

### Demonstration

> **Note:** The demonstration video is roughly 90MB, which exceeds GitHub's size limit for inline image previews.
>
> **[Click here to view or download the Demonstration Video (video.webm)](docs/assets/video.webm)**
