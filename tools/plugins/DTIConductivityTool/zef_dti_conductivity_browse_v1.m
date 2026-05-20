%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_BROWSE_V1
%
%Browse for FreeSurfer v1 file (principal eigenvector, optional).

function zef_dti_conductivity_browse_v1

zef = evalin('base','zef');

default_path = '';
if isfield(zef,'freesurfer_v1_file') && ~isempty(zef.freesurfer_v1_file)
    [default_path, ~, ~] = fileparts(zef.freesurfer_v1_file);
elseif isfield(zef,'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file)
    [default_path, ~, ~] = fileparts(zef.freesurfer_fa_file);
elseif isfield(zef,'save_file_path') && ~isempty(zef.save_file_path)
    default_path = zef.save_file_path;
else
    default_path = pwd;
end

[file_name, path_name] = uigetfile( ...
    {'*.nii.gz;*.nii', 'NIfTI (*.nii.gz, *.nii)'; '*.*', 'All Files'}, ...
    'Select v1 file (optional)', default_path);

if file_name ~= 0
    full_path = fullfile(path_name, file_name);
    zef.freesurfer_v1_file = full_path;
    if isfield(zef,'h_freesurfer_v1_file') && isvalid(zef.h_freesurfer_v1_file)
        zef.h_freesurfer_v1_file.Value = full_path;
    end
    assignin('base','zef',zef);
end

end
