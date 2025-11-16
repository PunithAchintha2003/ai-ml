function validate_modality(modality)
%% VALIDATE_MODALITY - Validate modality string
% Input:
%   modality: string to validate
% Throws error if invalid

    validModalities = {'accel', 'gyro', 'combined'};
    if ~ismember(lower(modality), validModalities)
        error('Invalid modality: %s. Choose from: %s', ...
            modality, strjoin(validModalities, ', '));
    end
end

