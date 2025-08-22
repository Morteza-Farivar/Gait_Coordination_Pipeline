# Step 07: Apply Hilbert Transform to Compute Phase Angles

This step computes the **instantaneous phase angle** (φ) of each gait cycle using the Hilbert Transform. These phase angles serve as the foundation for subsequent calculations of CRP, CRP variability, and interlimb coordination metrics.

---

## 🔍 Objective

To compute the phase angle of each signal (segment × axis) within each gait cycle using a custom, toolbox-free implementation of the Hilbert Transform.

---

## ⚙️ Processing Steps

1. **Validate Input**:
   - Confirm that `normalized_cycles_all` from Step 5 exists.

2. **Define Segments and Axes**:
   - Segments: `L_thigh`, `L_shank`, `L_foot`, `R_thigh`, `R_shank`, `R_foot`, `pelvis`, `trunk`
   - Axes: `X`, `Y`, `Z`

3. **Iterate over all files and trials**:
   - For each gait cycle:
     - Extract the signal of interest (e.g., `L_thigh_Y`)
     - Apply the Hilbert Transform (via `Hilbert_PA` function)
     - Store the resulting phase angle (in degrees) for each time point

4. **Store the output**:
   - `phase_angles.(segment).(axis){subject, trial}{cycle}`

---

## ✅ Key Concepts and Functions

- `Hilbert_PA()`: Custom function for Hilbert Transform using FFT and IFFT
- `angle()`: Computes the phase angle of the analytic signal
- `rad2deg()`: Converts radians to degrees
- Signals must be:
  - 1D vectors
  - Zero-centered
  - 100 data points long (from Step 5)
% Save phase angle data to Workspace
assignin('base', 'phase_angles', phase_angles);

disp('Step 7 completed: Phase angles saved successfully.');
