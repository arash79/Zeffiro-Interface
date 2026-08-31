function zef = zef_dti_conductivity_update(zef)
%ZEF_DTI_CONDUCTIVITY_UPDATE  Copy zef DTI fields onto the tool widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_dti_conductivity_update
%   zef = zef_dti_conductivity_update(zef)
%
%   nargin 0 → evalin('base','zef'). Returns immediately if
%   h_dti_conductivity_tool is missing or invalid. Syncs file-path edits,
%   status text, dropdowns. Does not load NIfTI or apply sigma.
%
%   See also zef_dti_conductivity_open, zef_dti_conductivity_init.
if nargin == 0
    zef = evalin('base','zef');
end

% Check if window exists and is valid
if ~isfield(zef,'h_dti_conductivity_tool')
    return;  % Window not created
end

try
    if ~isvalid(zef.h_dti_conductivity_tool)
        return;  % Window invalid
    end
catch
    return;  % Can't check validity, assume invalid
end

% ========================================================================
% UPDATE FILE PATHS
% ========================================================================

try
    if isfield(zef,'h_dti_ref_mri_file') && isvalid(zef.h_dti_ref_mri_file)
        if isfield(zef,'dti_ref_mri_file')
            zef.h_dti_ref_mri_file.Value = zef.dti_ref_mri_file;
        end
    end
catch
end

try
    if isfield(zef,'h_dti_ref_status') && isvalid(zef.h_dti_ref_status)
        if isfield(zef,'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
            rg = zef.dti_ref_geometry;
            zef.h_dti_ref_status.Text = sprintf('Geometry OK: %dx%dx%d, center [%.1f, %.1f, %.1f]', ...
                rg.dimensions(1), rg.dimensions(2), rg.dimensions(3), ...
                rg.center_ras(1), rg.center_ras(2), rg.center_ras(3));
            zef.h_dti_ref_status.FontColor = [0 0.7 0];
        else
            zef.h_dti_ref_status.Text = 'No reference MRI loaded';
            zef.h_dti_ref_status.FontColor = [0.5 0.5 0.5];
        end
    end
catch
end

try
    if isfield(zef,'h_freesurfer_fa_file') && isvalid(zef.h_freesurfer_fa_file)
        if isfield(zef,'freesurfer_fa_file')
            zef.h_freesurfer_fa_file.Value = zef.freesurfer_fa_file;
        end
    end
catch
end

try
    if isfield(zef,'h_freesurfer_v1_file') && isvalid(zef.h_freesurfer_v1_file)
        if isfield(zef,'freesurfer_v1_file')
            zef.h_freesurfer_v1_file.Value = zef.freesurfer_v1_file;
        end
    end
catch
end

try
    if isfield(zef,'h_freesurfer_register_file') && isvalid(zef.h_freesurfer_register_file)
        if isfield(zef,'freesurfer_register_file')
            zef.h_freesurfer_register_file.Value = zef.freesurfer_register_file;
        end
    end
catch
end

% ========================================================================
% UPDATE STATUS
% ========================================================================

try
    if isfield(zef,'h_dti_status_text') && isvalid(zef.h_dti_status_text)
        if isfield(zef,'dti_applied') && zef.dti_applied
            % Show applied status with optional tetra count
            if isfield(zef,'dti_conductivity_metadata') && isfield(zef.dti_conductivity_metadata,'n_tetrahedra_updated')
                n_up = zef.dti_conductivity_metadata.n_tetrahedra_updated;
                zef.h_dti_status_text.Text = sprintf('DTI conductivity applied (%d tetrahedra)', n_up);
            else
                zef.h_dti_status_text.Text = 'DTI conductivity applied';
            end
            zef.h_dti_status_text.FontColor = [0 0.7 0];
        elseif isfield(zef,'freesurfer_fa_loaded') && zef.freesurfer_fa_loaded && isfield(zef,'freesurfer_fa_data') && ~isempty(zef.freesurfer_fa_data)
            try
                [nx, ny, nz] = size(zef.freesurfer_fa_data);
                zef.h_dti_status_text.Text = sprintf('FreeSurfer FA loaded: %dx%dx%d', nx, ny, nz);
                zef.h_dti_status_text.FontColor = [0 0.7 0];
            catch
                zef.h_dti_status_text.Text = 'FreeSurfer FA data error';
                zef.h_dti_status_text.FontColor = [1 0 0];
            end
        else
            zef.h_dti_status_text.Text = 'No FreeSurfer FA data loaded';
            zef.h_dti_status_text.FontColor = [0.5 0.5 0.5];
        end
    end
catch
end

% ========================================================================
% UPDATE MODEL AND INTERPOLATION CONTROLS
% ========================================================================

if isfield(zef,'h_dti_model_dropdown') && isvalid(zef.h_dti_model_dropdown)
    if isfield(zef,'dti_conductivity_model')
        zef.h_dti_model_dropdown.Value = zef.dti_conductivity_model;
    end
end

if isfield(zef,'h_dti_volume_fraction') && isvalid(zef.h_dti_volume_fraction)
    if isfield(zef,'dti_volume_fraction')
        zef.h_dti_volume_fraction.Value = zef.dti_volume_fraction;
    end
end

if isfield(zef,'h_dti_extra_conductivity') && isvalid(zef.h_dti_extra_conductivity)
    if isfield(zef,'dti_extra_conductivity')
        zef.h_dti_extra_conductivity.Value = zef.dti_extra_conductivity;
    end
end

if isfield(zef,'h_dti_intra_conductivity') && isvalid(zef.h_dti_intra_conductivity)
    if isfield(zef,'dti_intra_conductivity')
        zef.h_dti_intra_conductivity.Value = zef.dti_intra_conductivity;
    end
end

if isfield(zef,'h_dti_conductivity_scale') && isvalid(zef.h_dti_conductivity_scale)
    if isfield(zef,'dti_conductivity_scale')
        zef.h_dti_conductivity_scale.Value = zef.dti_conductivity_scale;
    end
end

if isfield(zef,'h_dti_anisotropy_threshold') && isvalid(zef.h_dti_anisotropy_threshold)
    if isfield(zef,'dti_anisotropy_threshold')
        zef.h_dti_anisotropy_threshold.Value = zef.dti_anisotropy_threshold;
    end
end

if isfield(zef,'h_dti_mean_diffusivity') && isvalid(zef.h_dti_mean_diffusivity)
    if isfield(zef,'dti_mean_diffusivity')
        zef.h_dti_mean_diffusivity.Value = zef.dti_mean_diffusivity;
    end
end

if isfield(zef,'h_dti_interp_mode') && isvalid(zef.h_dti_interp_mode)
    if isfield(zef,'dti_interpolation_mode')
        zef.h_dti_interp_mode.Value = zef.dti_interpolation_mode;
    end
end

if isfield(zef,'h_dti_interp_radius') && isvalid(zef.h_dti_interp_radius)
    if isfield(zef,'dti_interpolation_radius')
        zef.h_dti_interp_radius.Value = zef.dti_interpolation_radius;
    end
end

% ========================================================================
% UPDATE COMPARTMENTS
% ========================================================================

if isfield(zef,'h_dti_compartments') && isvalid(zef.h_dti_compartments)
    if isa(zef.h_dti_compartments, 'matlab.ui.control.ListBox')
        % Rebuild items list
        try
            if isfield(zef,'compartment_tags') && ~isempty(zef.compartment_tags)
                compartment_items = {};
                compartment_items_data = {};
                for k = 1:length(zef.compartment_tags)
                    tag = zef.compartment_tags{k};
                    name_field = [tag '_name'];
                    if isfield(zef, name_field) && ~isempty(zef.(name_field))
                        comp_name = zef.(name_field);
                        if iscell(comp_name)
                            comp_name = comp_name{1};
                        elseif isstring(comp_name)
                            comp_name = char(comp_name);
                        end
                        if ~ischar(comp_name)
                            comp_name = tag;
                        end
                    else
                        comp_name = tag;
                    end
                    on_field = [tag '_on'];
                    if isfield(zef, on_field) && zef.(on_field)
                        comp_name = [comp_name ' (active)'];
                    else
                        comp_name = [comp_name ' (inactive)'];
                    end
                    compartment_items{end+1} = comp_name;
                    compartment_items_data{end+1} = tag;
                end
                zef.h_dti_compartments.Items = compartment_items;
                zef.h_dti_compartments.ItemsData = compartment_items_data;
            end
        catch
        end

        % Update selected values
        if isfield(zef,'dti_apply_to_compartments') && ~isempty(zef.dti_apply_to_compartments)
            if iscell(zef.dti_apply_to_compartments)
                selected_tags = zef.dti_apply_to_compartments;
            elseif ischar(zef.dti_apply_to_compartments) || isstring(zef.dti_apply_to_compartments)
                selected_tags = {char(zef.dti_apply_to_compartments)};
            else
                selected_tags = {};
            end
            if ~isempty(selected_tags) && ~isempty(zef.h_dti_compartments.ItemsData)
                valid_indices = ismember(selected_tags, zef.h_dti_compartments.ItemsData);
                selected_tags = selected_tags(valid_indices);
            end
            zef.h_dti_compartments.Value = selected_tags;
        else
            zef.h_dti_compartments.Value = {};
        end
    end
end

% ========================================================================
% UPDATE INFO TEXT
% ========================================================================

try
    if isfield(zef,'h_dti_info_text') && isvalid(zef.h_dti_info_text)
        info_lines = {};

        if isfield(zef,'freesurfer_fa_loaded') && zef.freesurfer_fa_loaded && isfield(zef,'freesurfer_fa_data') && ~isempty(zef.freesurfer_fa_data)
            try
                [nx, ny, nz] = size(zef.freesurfer_fa_data);
                info_lines{end+1} = sprintf('FreeSurfer FA Data: %dx%dx%d voxels', nx, ny, nz);
                if isfield(zef,'freesurfer_subject_name') && ~isempty(zef.freesurfer_subject_name)
                    info_lines{end+1} = sprintf('Subject: %s', zef.freesurfer_subject_name);
                end
            catch
                info_lines{end+1} = 'FreeSurfer FA data error';
            end
        else
            info_lines{end+1} = 'No FreeSurfer FA data loaded';
        end

        info_lines{end+1} = '';

        % Geometry status
        if isfield(zef,'dti_fa_geometry') && ~isempty(zef.dti_fa_geometry)
            info_lines{end+1} = sprintf('FA geometry: auto-extracted (%.1fx%.1fx%.1f mm voxels)', ...
                zef.dti_fa_geometry.voxel_sizes(1), zef.dti_fa_geometry.voxel_sizes(2), zef.dti_fa_geometry.voxel_sizes(3));
        end
        if isfield(zef,'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
            rg = zef.dti_ref_geometry;
            info_lines{end+1} = sprintf('Reference geometry: auto-extracted (%dx%dx%d, center [%.1f, %.1f, %.1f])', ...
                rg.dimensions(1), rg.dimensions(2), rg.dimensions(3), ...
                rg.center_ras(1), rg.center_ras(2), rg.center_ras(3));
        end

        info_lines{end+1} = '';

        if isfield(zef,'dti_applied') && zef.dti_applied
            info_lines{end+1} = 'DTI conductivity applied to mesh';
            if isfield(zef,'dti_conductivity_metadata')
                try
                    meta = zef.dti_conductivity_metadata;
                    info_lines{end+1} = sprintf('  Model: %d, Tetrahedra updated: %d', ...
                        meta.model_type, meta.n_tetrahedra_updated);
                    if isfield(meta, 'source')
                        info_lines{end+1} = sprintf('  Source: %s', meta.source);
                    end
                catch
                    info_lines{end+1} = '  Metadata available';
                end
            end
        else
            info_lines{end+1} = 'DTI conductivity not yet applied';
        end

        info_lines{end+1} = '';
        info_lines{end+1} = 'Click "Apply to Mesh" to update conductivity';

        zef.h_dti_info_text.Value = info_lines;
    end
catch
end

if nargout == 0
    assignin('base','zef',zef);
end

end
