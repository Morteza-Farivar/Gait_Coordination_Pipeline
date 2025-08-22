# Step 05: Normalize, Center, and Filter Gait Cycles

This step extracts individual gait cycles from the continuous motion capture data based on detected gait events, centers them around the mean, normalizes them to a standard length (100 points), and applies a simple moving average filter. These normalized cycles are required for accurate computation of phase angles and CRP.

---

## 🔍 Objective

To prepare gait cycles from raw kinematic data by:
1. Segmenting the data using heel/toe strike events
2. Centering each cycle to remove DC offset
3. Interpolating each cycle to 100 data points
4. Applying a moving average filter for smoothing

---

## ⚙️ Processing Steps

1. **Validate input**:
   - Ensure `df_drop_nan`, `Lheel_strikes_all`, and `Rheel_strikes_all` (or `toe_strikes_all` for BW) are defined

2. **Iterate over each subject and trial**

3. **For each gait cycle**:
   - Define start and end frames (e.g., from one left heel strike to the next)
   - Extract the segment of interest
   - Center the data by subtracting the mean
   - Interpolate the cycle to 100 points using `interp1`
   - Apply a moving average filter (`window size = 5`)

4. **Store results** in:
   - `centered_cycles_all`
   - `normalized_cycles_all`

---

## ✅ Key Concepts and Functions

- `interp1()` for linear resampling
- `mean(..., 'omitnan')` for DC offset removal
- `conv(..., 'same')` for moving average filtering
- Uses subject-wise and trial-wise loops
- Handles left-side events as reference for segmentation
