# Step 04b: Toe Strike Detection (Backward Walking)

This step identifies **toe strikes** during **backward walking (BW)** based on the vertical position of the toe markers (Y-axis). In backward walking, toe strike serves as the key event for defining gait cycles, replacing the role of heel strike used in forward walking.

---

## 🔍 Objective

To determine toe strikes for each trial using filtered toe marker signals and dynamic thresholding. Toe strike indices define gait cycles for later normalization and coordination analysis.

---

## ⚙️ Processing Steps

1. **Extract Y-coordinates** for left and right toe markers:
   - Left Toe Y = column 6
   - Right Toe Y = column 12

2. **Low-pass filter** both signals (Butterworth, 4th order, 10 Hz cutoff) to remove noise.

3. **Compute adaptive threshold**:
   - `Threshold = Mean - 0.5 * STD`
   - Ensures robustness to amplitude variation across subjects

4. **Set minimum peak distance**:
   - Based on walking speed assumption (0.6s → ~150 frames at 250Hz)

5. **Detect toe strikes**:
   - Invert signal and apply `findpeaks` to identify local minima representing toe strikes

6. **Store detected strike indices** for each leg and trial in structured variables:
   - `Ltoe_strikes_all` and `Rtoe_strikes_all`

---

## ✅ Key Concepts and Functions

- `filtfilt()` for zero-lag filtering (Butterworth)
- `findpeaks()` on negative signal for detecting local minima (toe strikes)
- Dynamic thresholding ensures subject-specific adaptability
- `MinPeakDistance` reduces false positives from noise or small movements
