# Step 04a: Heel Strike Detection (Forward Walking)

This step identifies **heel strikes** for each trial during **forward walking (FW)** using vertical heel marker data (Y-axis). Accurate heel strike detection is critical for defining gait cycles used in downstream calculations such as CRP, phase angles, and PCI.

---

## 🔍 Objective

To detect left and right heel strikes based on the vertical displacement signal (`Y` coordinate) of the left and right heel markers, and store the frame indices of those events for each trial (Zeni et al., 2008). 
Reference: Zeni, J. A., Richards, J. G., & Higginson, J. S. (2008). Two simple methods for determining gait events during treadmill and overground walking using kinematic data. Gait & Posture, 27(4), 710–714. https://doi.org/10.1016/j.gaitpost.2007.07.007

---

## ⚙️ Processing Steps

1. **Extract Y-axis heel marker data** for both feet:
   - Left Heel Y = column 3
   - Right Heel Y = column 9
2. **Normalize the signal**: Not required here, raw marker displacement is used.
3. **Detect local maxima**: Heel strikes are typically the local peaks in Y-axis heel position.
4. **Thresholding**: A minimum peak height is set (e.g., 30% of max signal) to suppress noise.
5. **Minimum peak distance**: Avoids detecting multiple strikes in a short span.
6. **Store the peak indices** in:
   - `Lheel_strikes_all`
   - `Rheel_strikes_all`

---

## ✅ Key Concepts and Functions

- `detect_peaks()`: Custom function to find local maxima
- `for` loop: Iterates over subjects and trials
- `max(Y)`: Used to set a relative detection threshold (e.g., `0.3 * max`)
- `modularity`: Allows this logic to be replaced by `findpeaks()` if Signal Toolbox is available

---

## 🧪 Sample Code Snippet

```matlab
% Thresholds and distance
threshold_L = 0.3 * max(LHeel_Y);
threshold_R = 0.3 * max(RHeel_Y);
min_distance = 50;

% Detect local peaks (heel strikes)
L_peaks = detect_peaks(LHeel_Y, threshold_L, min_distance);
R_peaks = detect_peaks(RHeel_Y, threshold_R, min_distance);

Lheel_strikes_all{file_idx, trial_idx} = L_peaks;
Rheel_strikes_all{file_idx, trial_idx} = R_peaks;
