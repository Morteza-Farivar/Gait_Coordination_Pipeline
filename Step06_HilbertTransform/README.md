# Step 06: Define Helper Function for Hilbert Transform

This step defines a reusable helper function named `Hilbert_PA` for computing phase angles from a motion signal using the Hilbert Transform. This function will be called in later steps (e.g., Step 07) to calculate the instantaneous phase of segmental angular data.

---

## 🧠 Purpose

To create a standalone MATLAB function that:
- Accepts a one-dimensional signal (e.g., joint angle in degrees)
- Centers the signal around zero
- Applies the Hilbert Transform to compute the analytic signal
- Extracts the instantaneous phase angle (in degrees)

---

## 🧮 Function Details

### 🔧 **Function Name**: `Hilbert_PA`

### 📥 Input
- `signal`: A numeric 1D array (e.g., segment angle or velocity)
  - Must be non-empty and contain numeric values
  - Can contain `NaN` values (they will be handled during centering)

### 📤 Output
- `phase_angle`: A 1D array of phase angles in **degrees**

---

## 🔁 Processing Steps

1. **Input validation**:
   - Checks if input is numeric and non-empty.
   - Warns if `NaN` values are present.

2. **Zero centering**:
   - Removes the mean from the signal using `omitnan` to handle missing data.

3. **Hilbert Transform**:
   - Uses MATLAB’s built-in `hilbert()` function to compute the analytic signal.

4. **Phase angle extraction**:
   - Converts the complex phase from radians to degrees using `angle()` and `rad2deg()`.

---

## 📦 MATLAB Code

%% Step 6: Define Helper Function for Hilbert Transform

% Function to compute the phase angle of a signal using Hilbert Transform
% Input:
%   signal - Numeric array (joint angle or motion data in degrees)
% Output:
%   phase_angle - Phase angles in degrees
function phase_angle = Hilbert_PA(signal)
    % Validate input
    if ~isnumeric(signal) || isempty(signal)
        error('Input signal must be a non-empty numeric array.');
    end

    % Check for NaN values and warn
    if any(isnan(signal))
        warning('Input signal contains NaN values. These will be ignored during Hilbert Transform.');
    end

    % Center the signal around zero before Hilbert Transform
    centered_signal = signal - mean(signal, 'omitnan'); % Ignore NaNs during centering

    % Apply Hilbert Transform to compute phase angles
    analytic_signal = hilbert(centered_signal); % Compute analytic signal

    % Compute phase angle in degrees
    phase_angle = rad2deg(angle(analytic_signal)); % Convert radians to degrees
end
