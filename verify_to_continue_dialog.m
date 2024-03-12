function shouldContinue = verify_to_continue_dialog()
    % Create the dialog box
    choice = questdlg('Please verify all inputs are correct', ...
        'Continue?', ...
        'Yes','No','No'); % Set the default to 'Yes'
    
    % Handle the user's choice
    switch choice
        case 'Yes'
            % The user chose to continue
            shouldContinue = true;
        case 'No'
            % The user chose to terminate
            shouldContinue = false;
        otherwise
            % The user closed the dialog or clicked cancel
            shouldContinue = false;
    end
end
