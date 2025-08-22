# Step 01: Load Gait Data and Validate Files

This step initializes the pipeline by loading gait segment calculation data from Excel files exported from Visual3D or any other biomechanical software.

## 🔍 Objective
To scan a target folder, detect only the relevant Excel files with correct naming format (e.g., `S01_FW_SegCalc.xlsx`, `S20_BW_SegCalc.xlsx`), and exclude any file that does not match the pattern. This ensures that subsequent processing steps only apply to valid and expected datasets.

## 📂 File Naming Convention
Each file must follow the pattern:  
`S##_(FW|BW)_SegCalc.xlsx`  
Where:
- `S##`: Subject number (e.g., S01, S20)
- `FW` or `BW`: Walking direction (Forward or Backward)
- `SegCalc`: Segment calculation data from Visual3D

Example of valid filenames:
- `S01_FW_SegCalc.xlsx`
- `S15_BW_SegCalc.xlsx`

## ⚙️ Processing Steps

1. **Define the data directory** containing all Excel files.
2. **List all `.xlsx` files** in that folder.
3. **Filter** the files to keep only those matching the naming pattern using regular expressions.
4. **Display summaries** of the files that will be processed.
5. **Preallocate data structures** (e.g., a master table) for further analysis.

## ✅ Key Functions and Concepts
- `dir()`: Lists all files in a folder
- `regexp()`: Ensures file names match the required format
- `readtable()`: Reads Excel files into MATLAB
- **Robust error-checking**: If no valid files are found, processing stops with an error message
- **Preallocation**: For improved performance in the next steps


## 📌 Code Snippet (for demonstration only)

%% Step 1: Load Data

% Directory Setup
data_folder = 'C:\.....'; % Full path to the folder
disp(['Checking folder: ', data_folder]);

% List all Excel files in the folder
d = dir(fullfile(data_folder, '*.xlsx')); % List all Excel files in the folder

% Check if files are detected
if isempty(d)
    error('No Excel files found in the folder: %s. Please check the folder path.', data_folder);
else
    disp('Files found in the folder:');
    for i = 1:length(d)
        disp(d(i).name);
    end
end

% Preallocate valid_files with the maximum possible size
valid_files = repmat(struct('name', '', 'folder', '', 'date', '', ...
    'bytes', 0, 'isdir', false, 'datenum', 0), length(d), 1);

valid_count = 0; % Counter to track the number of valid files

for i = 1:length(d)
    % Extract file name
    filename = d(i).name;

    % Validate file name format (e.g., S01_FW_SegCalc.xlsx or S20_BW_SegCalc.xlsx)
    match = regexp(filename, '^S\d{2}_(FW|BW)_SegCalc\.xlsx$', 'once');
    if ~isempty(match)
        valid_count = valid_count + 1; % Increment valid file counter
        valid_files(valid_count) = d(i); % Add the file to valid_files
    else
        disp(['Skipping file: ', filename, '. Invalid subject ID format.']);
    end
end

% Trim valid_files to remove unused preallocated elements
valid_files = valid_files(1:valid_count);

% Update the file list to only include valid files
d = valid_files;


% Display summary of valid files
if isempty(d)
    error('No valid files found in the folder: %s. Please check the file names.', data_folder);
else
    disp(['Valid files detected: ', num2str(length(d))]);
    for i = 1:length(d)
        disp(d(i).name);
    end
end

% Marker Filter Parameters
samp_freq = 250;              % Sampling frequency (Hz)
marker_dt = 1 / samp_freq;    % Sampling interval (seconds)
marker_cutoff = 10;           % Cutoff frequency for filter (Hz)
marker_ftype = 'low';         % Filter type ('low' for low-pass, 'high' for high-pass)
marker_forder = 4;            % Filter order

% Trials for processing
trials = ["walk100", "walk120", "walk140", "walk160", "walk60", "walk80"];

% Preallocate master_table
total_trials = length(d) * length(trials) * 3; % 3 components (X, Y, Z)
master_table = table(cell(total_trials, 1), ... % Subject
    cell(total_trials, 1), ... % Trials
    cell(total_trials, 1), ... % Direction
    cell(total_trials, 1), ... % Side (Left/Right/Interlimb)
    cell(total_trials, 1), ... % Component (X/Y/Z)
    cell(total_trials, 1), ... % Segment_Coupling (e.g., Thigh-Shank, Shank-Foot, Trunk-Pelvis, Thigh, Shank, Foot)
    NaN(total_trials, 1), ... % CRP
    NaN(total_trials, 1), ... % CRP_Variability
    NaN(total_trials, 1), ... % PCI
    'VariableNames', {'Subject', 'Trials', 'Direction', 'Side', 'Component', 'Segment_Coupling', 'CRP', 'CRP_Variability', 'PCI'});

% Initialize row index for master_table
row_idx = 1;

% Initialize df_list to store sliced data for all trials
df_list = cell(length(d), length(trials)); % Adjusted for all files and trials

% Loop through each file
for file_idx = 1:length(d)
    filename = d(file_idx).name; % Current file name
    filepath = fullfile(data_folder, filename);

    % Extract subject ID and walking direction from filename
    subj_id = extractBetween(filename, 'S', '_'); % Extract subject number
    if isempty(subj_id)
        disp(['Skipping file: ', filename, '. Could not extract subject ID.']);
        continue;
    end
    subj_id = ['S', subj_id{1}]; % Add "S" to ensure consistency

    % Determine direction (Forward or Backward Walking)
    if contains(filename, '_FW')
        direction = 'FW'; % Forward Walking
    elseif contains(filename, '_BW')
        direction = 'BW'; % Backward Walking
    else
        disp(['Unrecognized file: ', filename]);
        continue; % Skip unrecognized files
    end

    % Read data from Excel file
    try
        data = readtable(filepath); % Column headers will be auto-adjusted
    catch ME
        disp(['Error reading file: ', filename, '. Skipping...']);
        disp(['Error Message: ', ME.message]);
        continue; % Skip to the next file
    end

    % Slice data into trials and store in df_list
    for trial_idx = 1:length(trials)
        start_col = 2 + (trial_idx - 1) * 36; % Start column for the trial
        end_col = 1 + trial_idx * 36;         % End column for the trial

        % Ensure column indices are within bounds
        if end_col <= size(data, 2)
            df_list{file_idx, trial_idx} = data(:, [1, start_col:end_col]); % Include time (column 1) and trial columns
        else
            disp(['Skipping trial ', char(trials(trial_idx)), ' for file ', filename, ': Columns exceed dataset size.']);
            df_list{file_idx, trial_idx} = []; % Assign empty if out of bounds
        end
    end

    % Update master_table with metadata (subject, trial, direction, components)
    for trial_idx = 1:length(trials)
        if ~isempty(df_list{file_idx, trial_idx})
            for component = ["X", "Y", "Z"]
                % Populate master_table row by row
                master_table.Subject{row_idx} = subj_id;
                master_table.Trials{row_idx} = char(trials(trial_idx));
                master_table.Direction{row_idx} = direction;
                master_table.Component{row_idx} = component;
                master_table.Side{row_idx} = ''; % Leave blank for now
                master_table.Segment_Coupling{row_idx} = ''; % Leave blank for now
                row_idx = row_idx + 1;
            end
        end
    end
end

% Trim master_table to remove unused preallocated rows
master_table = master_table(1:row_idx-1, :);

% Display summary
disp(['Step 1 completed: ', num2str(length(d)), ' valid files processed.']);
disp(['Master table contains ', num2str(height(master_table)), ' rows.']);
disp(['df_list size: ', num2str(size(df_list, 1)), ' x ', num2str(size(df_list, 2))]);

if isempty(valid_files)
    error('No valid files found. Check your filenames.');
end
