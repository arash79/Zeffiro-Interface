function [zef, report] = import_duneuro_project(zef, source)
%IMPORT_DUNEURO_PROJECT  Convert a DUNEuro project and merge it into a Zeffiro session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   This is the session entry for DUNEuro import. Open project (zef_load)
%   calls convert() directly on DUNEuro MAT files so File → Open project
%   is the same path. This function also supports a folder of DUNEuro
%   export files and a GUI picker when source is omitted.
%
%   zef = import_duneuro_project(zef, path)
%   zef = import_duneuro_project(path)            % reads zef from base
%   zef = import_duneuro_project(zef)             % uigetfile picker
%   [zef, report] = import_duneuro_project(...)
%
%   See also convert, run, zef_load.

    if nargin == 1 && (ischar(zef) || isstring(zef) || isstruct(zef) && ~isfield(zef, 'program_path'))
        source = zef;
        if evalin('base', 'exist(''zef'',''var'')')
            zef = evalin('base', 'zef');
        else
            error('duneuro2zef:NoSession', ...
                'Pass a zef session as the first argument, or have zef in the base workspace.');
        end
    elseif nargin < 1 || isempty(zef)
        if evalin('base', 'exist(''zef'',''var'')')
            zef = evalin('base', 'zef');
        else
            error('duneuro2zef:NoSession', 'No zef session is available.');
        end
        source = [];
    end

    if nargin < 2
        source = [];
    end

    if isempty(source)
        start_path = pwd;
        if isfield(zef, 'save_file_path') && ~isempty(zef.save_file_path) && ~isequal(zef.save_file_path, 0)
            start_path = zef.save_file_path;
        end
        [file_name, path_name] = uigetfile( ...
            {'*.mat', 'DUNEuro MATLAB file (*.mat)'}, ...
            'Import DUNEuro project', start_path);
        if isequal(file_name, 0)
            report = struct('cancelled', true);
            return
        end
        source = fullfile(path_name, file_name);
    end

    [payload, report] = utilities.duneuro2zef.convert(source);
    zef = local_apply_payload(zef, payload, source);

    if isfield(zef, 'h_sensors_table') && isvalid(zef.h_sensors_table)
        try
            zef = zef_build_sensors_table(zef);
        catch
        end
    end
    if isfield(zef, 'h_compartment_table') && isvalid(zef.h_compartment_table)
        try
            zef = zef_build_compartment_table(zef);
        catch
        end
    end
    try
        zef = zef_update(zef);
    catch
    end

    if nargout == 0
        assignin('base', 'zef', zef);
    end
end

function zef = local_apply_payload(zef, payload, source)
    names = fieldnames(payload);
    for i = 1:numel(names)
        zef.(names{i}) = payload.(names{i});
    end

    if isfield(payload, 'sensor_tags') && ~isempty(payload.sensor_tags)
        for i = 1:numel(payload.sensor_tags)
            zef = zef_create_sensors(zef, payload.sensor_tags{i});
        end
        if isfield(payload, 's_points')
            zef.s_points = payload.s_points;
        end
        if isfield(payload, 's_name_list')
            zef.s_name_list = payload.s_name_list;
        end
        if isfield(payload, 's_imaging_method_name')
            zef.s_imaging_method_name = payload.s_imaging_method_name;
        end
        if isfield(payload, 's_name')
            zef.s_name = payload.s_name;
        end
        zef.s_on = 1;
        zef.s_visible = 1;
        zef.sensors = payload.sensors;
        zef.current_sensors = 's';
    end

    if isfield(payload, 'compartment_tags')
        for i = 1:numel(payload.compartment_tags)
            zef = zef_create_compartment(zef, payload.compartment_tags{i});
        end
    end

    if ischar(source) || isstring(source)
        [path_name, file_name, ext] = fileparts(char(source));
        if ~isempty(file_name)
            zef.save_file = [file_name, ext];
            if ~isempty(path_name)
                zef.save_file_path = [path_name, filesep];
            end
        end
    end
end
