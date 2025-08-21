# Step 08: Compute CRP and CRP Variability for All Gait Cycles

This step calculates **Continuous Relative Phase (CRP)** and **CRP Variability** for multiple segmental couplings and directional axes using the phase angles derived in Step 07. These metrics quantify the temporal coordination and variability between two segments across the gait cycle.

---

## 🧠 Purpose

- **CRP** quantifies the coordination between two body segments (e.g., thigh and shank) over time.
- **CRP Variability** assesses consistency in coordination across repeated gait cycles.
- These measures are central to evaluating **interlimb** and **intralimb** coordination during gait, especially in clinical populations such as those with Parkinson's Disease or ACL reconstruction.

---

## 🔁 Processing Logic

1. **Validate Inputs**
   - Ensures `phase_angles` structure exists and is not empty.

2. **Define Segment Couplings**
   - Example pairs:
     - `L_thigh`–`L_shank`
     - `R_thigh`–`pelvis`
     - `trunk`–`pelvis`
   - Each coupling is assessed on X, Y, and Z axes.

3. **Loop Through Files and Trials**
   - For each file and trial, extracts phase angles for distal and proximal segments.
   - Computes CRP for all gait cycles using:
     \[
     \text{CRP}(t) = \phi_{\text{distal}}(t) - \phi_{\text{proximal}}(t)
     \]

4. **Wrap Angles**
   - Phase differences are wrapped to the range **[-180°, 180°]** using:
     \[
     \text{CRP}_{\text{wrapped}} = \mod(\text{CRP} + 180, 360) - 180
     \]

5. **Compute CRP Variability**
   - For each point in the gait cycle (1–100%), the standard deviation across cycles is calculated:
     \[
     \text{CRP}_\text{variability}(t) = \text{std}(\text{CRP}(t) - \text{mean}(\text{CRP}(t)))
     \]

---

## 🧮 Output Variables

### 📌 `crp_all`
- Structure: `crp_all.segment_coupling.axis{file, trial}`
- Data: Matrix [num_cycles × 100] representing CRP over 100 time-normalized gait points.

### 📌 `crp_variability`
- Structure: `crp_variability.segment_coupling.axis{file, trial}`
- Data: Vector [1 × 100] representing variability in CRP across cycles.

---

## ⚠️ Error and Warning Handling

- Skips trials with missing or extreme phase angle values (outside ±360°).
- Warns if any NaNs are encountered in inputs or if data is insufficient.

---

## 💾 Output Storage

The following are saved to the MATLAB Workspace:
- `crp_all`
- `crp_variability`

---

## ⏱️ Runtime Tip

This step can be computationally intensive depending on the number of gait cycles per subject and trial. Consider batching if working with large datasets.

---

## ✅ Example Output Access

```matlab
% View CRP for L_thigh–L_shank coupling on Y-axis for subject 1, trial 1
crp_plot = crp_all.L_thigh_L_shank.Y{1, 1};

% Plot CRP for first gait cycle
plot(linspace(0, 100, 100), crp_plot(1, :));
xlabel('Gait Cycle (%)'); ylabel('CRP (deg)'); title('CRP: L_thigh–L_shank, Y-axis');

% Plot variability
variability = crp_variability.L_thigh_L_shank.Y{1, 1};
plot(linspace(0, 100, 100), variability);
xlabel('Gait Cycle (%)'); ylabel('CRP Variability (deg)'); title('CRP Variability');
