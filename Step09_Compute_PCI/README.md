## Step 09: Compute Gait Timing and Phase Coordination Index (PCI)

This step contains **two sub-modules** for computing gait timing and Phase Coordination Index (PCI) based on right and left leg timing metrics. The calculations are saved in the MATLAB workspace as `cell` arrays indexed by file and trial.

Reference: Plotnik et al., 2007
Plotnik, M., Giladi, N., & Hausdorff, J. M. (2007). A new measure for quantifying the bilateral coordination of human gait: Effects of aging and Parkinson’s disease. Experimental Brain Research, 181(4), 561–570. https://doi.org/10.1007/s00221-007-0955-7 

---

### 📌 Step 9a: Calculate Toe-Off, Stride Time, Step Time, and Swing Time

**Purpose**: Extract fundamental gait timing variables from toe and heel marker trajectories.

**Key Outputs**:
- `toe_off_left`, `toe_off_right`: Frame indices of toe-off events (local minima)
- `stride_time_left`, `stride_time_right`: Frame differences between successive ipsilateral heel strikes
- `step_time_left`, `step_time_right`: Frame differences between alternating foot contacts
- `swing_time_left`, `swing_time_right`: Time between toe-off and next ipsilateral heel strike

**Inputs Required**:
- `df_drop_nan`: Cleaned marker trajectories
- `Lheel_strikes_all`, `Rheel_strikes_all`: Heel strike indices from previous steps

**Approach**:
- Detect toe-off as local minima of toe markers
- Use frame indices of heel strikes to compute stride, step, and swing times

All metrics are calculated per file and per trial and saved as `cell` arrays.

---

### 📌 Step 9b: Compute PCI from Timing Metrics

**Purpose**: Quantify **bilateral gait coordination** using Phase Coordination Index (PCI), based on relative phase timing.

**Key Definitions**:
- `φ (phi)`: Average phase between contralateral foot contacts
- `φ_ABS`: Absolute deviation from ideal 180° phase
- `φ_CV`: Coefficient of variation of phase (normalized variability)
- `PCI`: Composite metric defined as:

\[ \text{PCI} = \phi_{CV} + \left( \frac{\phi_{ABS}}{180} \right) \times 100 \]

**Inputs Required**:
- `stride_time_right`, `stride_time_left`
- `step_time_right`, `step_time_left`

**Procedure**:
1. Use the stride time of one leg and step time of the opposite leg to compute relative phase:
   \[ \phi = \mod\left( \frac{360 \times \text{Step Time}}{\text{Stride Time}}, 360 \right) \]
2. Reflect any φ values >180° across the 180° axis to ensure symmetry.
3. Calculate:
   - `φ`: Mean phase
   - `φ_ABS`: Mean absolute deviation from 180°
   - `φ_CV`: Standard deviation normalized by the mean φ
   - `PCI`: Composite score

**Output Variables (as cell arrays)**:
- `R_phi`, `L_phi`: Mean phase
- `R_phi_abs`, `L_phi_abs`: Absolute deviation
- `R_phi_cv`, `L_phi_cv`: Coefficient of variation
- `pci`: Final PCI score
