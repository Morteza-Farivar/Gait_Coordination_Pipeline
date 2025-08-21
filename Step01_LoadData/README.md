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

```matlab
data_folder = 'your_path_here';
d = dir(fullfile(data_folder, '*.xlsx'));

valid_files = [];
for i = 1:length(d)
    filename = d(i).name;
    if ~isempty(regexp(filename, '^S\d{2}_(FW|BW)_SegCalc\.xlsx$', 'once'))
        valid_files(end+1) = d(i);
    end
end

if isempty(valid_files)
    error('No valid files found. Check your filenames.');
end
