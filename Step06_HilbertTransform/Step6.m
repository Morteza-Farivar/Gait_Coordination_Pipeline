%% Step 6: Define Helper Function for Hilbert Transform (Toolbox-Free)

% Function to compute the phase angle of a signal using Hilbert Transform (no toolbox)
% Input:
%   signal - Numeric array (joint angle or motion data in degrees)
% Output:
%   phase_angle - Phase angles in degrees
function phase_angle = Hilbert_PA(signal)
    % Validate input
    if ~isnumeric(signal) || isempty(signal)
        error('Input signal must be a non-empty numeric array.');
    end

    % Check for NaN values
    if any(isnan(signal))
        warning('Input signal contains NaN values. These will be ignored during Hilbert Transform.');
    end

    % Center the signal around zero
    centered_signal = signal - mean(signal, 'omitnan');
    centered_signal = centered_signal(:);  % Ensure column vector

    % Compute FFT-based analytic signal (Toolbox-Free)
    N = length(centered_signal);
    X = fft(centered_signal);

    H = zeros(N, 1);
    if mod(N, 2) == 0
        % Even-length signal
        H(1) = 1;
        H(N/2 + 1) = 1;
        H(2:N/2) = 2;
    else
        % Odd-length signal
        H(1) = 1;
        H(2:(N+1)/2) = 2;
    end

    analytic_signal = ifft(X .* H);

    % Extract phase angle and convert to degrees
    phase_angle = rad2deg(angle(analytic_signal));
end