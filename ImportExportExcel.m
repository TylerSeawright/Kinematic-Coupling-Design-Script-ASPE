% Read or Write Excel Data

% Parameter Definitions
% - mode = 'r' for read or 'w' for write
% - excelData = 0 for none or cell{} matrix for saving excel data
% - msg = custom message for dialogue box, e.g. select material library
function excelData = ImportExportExcel(mode, excelData, msg)

    % If the mode is 'r', open a file dialog box to select an Excel file to read
    if mode == 'r'
        [fileName, filePath] = uigetfile('*.xlsx', msg);
        excelFile = fullfile(filePath, fileName);
        excelData = readtable(excelFile,'PreserveVariableNames',true);

    % If the mode is 'w', prompt the user to enter a file name to write the data to
    elseif mode == 'w'
        [fileName, filePath] = uiputfile('*.xlsx', msg);
        excelFile = fullfile(filePath, fileName);
        writematrix(excelData, excelFile);

    % If the mode is neither 'r' nor 'w', display an error message
    else
        error('Invalid mode argument. Use ''r'' for read or ''w'' for write.');
    end
end