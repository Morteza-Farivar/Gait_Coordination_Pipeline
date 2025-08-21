# Step 06: Compute Phase Angles using Hilbert Transform (Toolbox-Free)

This step computes the **instantaneous phase angle** of segment motion using a custom Hilbert Transform function. The computed phase angles will be used to evaluate continuous relative phase (CRP), phase variability, and PCI.

---

## 🔍 Objective

To compute the phase angle (φ) of each 100-point gait cycle for every axis (X, Y, Z) of the following body segments:

- `L_thigh`, `L_shank`, `L_foot`
- `R_thigh`, `R_shank`, `R_foot`
- `pelvis`, `trunk`

---

## ⚙️ Processing Steps

1. **Validate input**:
   - Ensure `normalized_cycles_all` exists

2. **Define segment list**:
   - All segments and axes (X, Y, Z) to be processed

3. **Loop through subject × trial × cycle**:
   - Extract the 100-point time series for each segment-axis
   - Apply Hilbert transform to compute instantaneous phase angle

4. **Store results** in a structured variable:
   - `phase_angles.(segment).(axis){subject, trial}{cycle}`

---

## ✅ Key Concepts and Functions

- **Hilbert Transform**: Extracts the analytical signal and calculates its angle in degrees.
- Implemented using:
  - `fft()` for frequency domain conversion
  - Zeroing negative frequencies
  - `ifft()` to reconstruct the analytical signal
- Custom implementation is toolbox-free (no Signal Processing Toolbox required)
- Input signals must be:
  - 1D vectors
  - Centered (mean-subtracted)
  - Length = 100

---

## 🧪 Code Snippet (demonstration)

```matlab
function phase_angle = Hilbert_PA(signal)
    % Center signal
    centered_signal = signal - mean(signal, 'omitnan');
    N = length(centered_signal);
    X = fft(centered_signal);

    % Construct Hilbert filter
    H = zeros(N,1);
    if mod(N, 2) == 0
        H(1) = 1; H(N/2+1) = 1; H(2:N/2) = 2;
    else
        H(1) = 1; H(2:(N+1)/2) = 2;
    end

    % Compute analytic signal
    analytic_signal = ifft(X .* H);
    phase_angle = rad2deg(angle(analytic_signal));
end
