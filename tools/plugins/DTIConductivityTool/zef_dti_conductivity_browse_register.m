%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_BROWSE_REGISTER
%
%Browse for FreeSurfer register.dat file (from dt_recon).

function zef_dti_conductivity_browse_register

zef = evalin('base','zef');

default_path = '';
if isfield(zef,'freesurfer_register_file') && ~isempty(zef.freesurfer_register_file)
    [default_path, ~, ~] = fileparts(zef.freesurfer_register_file);
elseif isfield(zef,'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file)
    [default_path, ~, ~] = fileparts(zef.freesurfer_fa_file);
elseif isfield(zef,'save_file_path') && ~isempty(zef.save_file_path)
    default_path = zef.save_file_path;
else
    default_path = pwd;
end

[file_name, path_name] = uigetfile( ...
    {'*register*.dat;*.dat', 'register.dat'; '*.*', 'All Files'}, ...
    'Select register.dat', default_path);

if file_name ~= 0
    full_path = fullfile(path_name, file_name);
    zef.freesurfer_register_file = full_path;
    if isfield(zef,'h_freesurfer_register_file') && isvalid(zef.h_freesurfer_register_file)
        zef.h_freesurfer_register_file.Value = full_path;
    end
    assignin('base','zef',zef);
end

end
