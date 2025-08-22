# Step 02: Clean Gait Data by Removing NaN Rows

This step ensures the integrity of the gait data by removing any rows with missing values (`NaN`) from each trial. Cleaning the data at this early stage is critical for accurate segmentation, normalization, and downstream computation of CRP and PCI.

---

## 🔍 Objective

To clean each trial dataset by:
- Iterating through all subject-trial combinations
- Identifying and removing any rows that contain missing values
- Returning a clean version of the dataset for further processing

---

## ⚙️ Processing Steps

1. Validate that the data structure `df_list` (from Step 01) exists.
2. Iterate over each file and each trial within the `df_list` cell array.
3. For each non-empty table:
   - Convert the table to a numeric array (if needed)
   - Remove any rows that contain `NaN` values
4. Store cleaned data in a new variable `df_drop_nan`.

---

## ✅ Key Concepts and Functions

- `isnan()`: Checks for missing values
- `any(..., 2)`: Detects if any value in a row is `NaN`
- `table2array()`: Converts table to numeric array for processing
- `cell`: Data is stored in a 2D cell array by subject × trial
- `assignin('base', ...)`: Stores the cleaned result in the MATLAB base workspace

---

## 💡 Why This Step Is Important

- Ensures that no invalid or partial data skews results
- Prevents errors during signal filtering, gait cycle detection, and phase angle computation
- Makes the analysis reproducible and robust, especially for batch processing

---

## 🧪 Code Snippet (demonstration only)

%% Step 2: Data Cleaning for Empty Rows

disp('Step 2: Cleaning data to remove rows with NaN values...');

% Call the clean_data function
df_drop_nan = clean_data(df_list);

% Validate and save df_drop_nan to the workspace
if ~isempty(df_drop_nan)
    assignin('base', 'df_drop_nan', df_drop_nan);
    disp('Step 2 completed: Cleaned data saved as df_drop_nan.');
else
    error('Step 2 failed: df_drop_nan is empty.');
end

% Function Definition: clean_data
function cleaned_trials = clean_data(data_list)
    % Clean data by removing rows with NaN values from each trial.
    %
    % Parameters:
    % - data_list: A cell array where each cell contains a table or array
    %              representing trial data.
    %
    % Returns:
    % - cleaned_trials: A cell array with the same structure as data_list,
    %                   but with rows containing NaN values removed.

    % Validate input
    if ~iscell(data_list)
        error('Input data_list must be a cell array.');
    end

    % Initialize cell array for cleaned data
    cleaned_trials = cell(size(data_list));

    for trial_idx = 1:numel(data_list)
        % Check if the trial data is non-empty
        if ~isempty(data_list{trial_idx})
            trial_data = data_list{trial_idx};

            % Convert table to array if trial_data is a table
            if istable(trial_data)
                trial_data = table2array(trial_data);
            end

            % Remove rows with any NaN values
            cleaned_trials{trial_idx} = trial_data(~any(isnan(trial_data), 2), :);

            % Display the number of rows removed
            rows_removed = size(trial_data, 1) - size(cleaned_trials{trial_idx}, 1);
            disp(['Trial ', num2str(trial_idx), ': ', num2str(rows_removed), ...
                ' rows removed due to missing values.']);
        else
            disp(['Trial ', num2str(trial_idx), ' is empty. Skipping.']);
            cleaned_trials{trial_idx} = [];
        end
    end

    % Summary message
    disp(['Data cleaning completed for ', num2str(numel(data_list)), ' trials.']);
    
    % Debugging output for cleaned trials
    disp('Summary of cleaned trials:');
    for trial_idx = 1:numel(cleaned_trials)
        if ~isempty(cleaned_trials{trial_idx})
            disp(['Trial ', num2str(trial_idx), ': ', ...
                  num2str(size(cleaned_trials{trial_idx}, 1)), ' rows and ', ...
                  num2str(size(cleaned_trials{trial_idx}, 2)), ' columns.']);
        else
            disp(['Trial ', num2str(trial_idx), ': Empty after cleaning.']);
        end
    end
end
