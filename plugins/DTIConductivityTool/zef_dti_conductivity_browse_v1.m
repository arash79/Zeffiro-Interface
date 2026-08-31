function zef_dti_conductivity_browse_v1
%ZEF_DTI_CONDUCTIVITY_BROWSE_V1  uigetfile NIfTI → zef.freesurfer_v1_file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_dti_conductivity_browse_v1
%
%   Optional principal-eigenvector volume. Default folder: existing v1,
%   else FA, else save_file_path, else pwd. Cancel is a no-op.
%
%   See also zef_dti_conductivity_browse_fa, zef_dti_conductivity_browse_register.

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
