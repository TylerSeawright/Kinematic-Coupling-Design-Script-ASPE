% MATLAB Script to Read Data from an Excel File

% Specify the file name of the Excel file
function data = ImportExcel(filename)

    % Check if the file exists in the current directory
    if isfile(filename)
        % Import the data from the Excel file
        data = readtable(filename,'PreserveVariableNames',true);
        
    else
        % Display an error message if the file does not exist
        disp(['Error: The file ' filename ' does not exist in the current directory.']);
    end

end