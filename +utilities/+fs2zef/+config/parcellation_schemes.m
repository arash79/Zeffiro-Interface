function schemes = parcellation_schemes()
% --- Zeffiro documentation header ---
% utilities.fs2zef.config.parcellation_schemes — Parcellation schemes.
%
% Purpose:
%   Parcellation schemes.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Outputs:
%   schemes
%
% Calls (project):
%   utilities.fs2zef.config.parcellation_schemes
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `utilities.fs2zef.config.parcellation_schemes` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

%
% parcellation_schemes - Define available cortical parcellation schemes
%
% Returns information about supported FreeSurfer parcellation schemes including
% number of labels, annotation file names, and human-readable names.
%
% Outputs:
%   schemes - Struct with parcellation scheme definitions
%

    schemes = struct();
    
    % Desikan-Killiany Atlas (34 cortical ROIs per hemisphere)
    schemes.desikan_killiany.labels = 36;
    schemes.desikan_killiany.annotation = 'aparc';
    schemes.desikan_killiany.ctab = 'aparc.annot';
    schemes.desikan_killiany.name = 'Desikan-Killiany';
    schemes.desikan_killiany.description = 'Standard Desikan-Killiany parcellation (36 labels)';
    schemes.desikan_killiany.reference = 'Desikan et al., 2006, NeuroImage';
    schemes.desikan_killiany.id = '36';
    
    % Destrieux Atlas (74 cortical ROIs per hemisphere)
    schemes.destrieux.labels = 76;
    schemes.destrieux.annotation = 'aparc.a2009s';
    schemes.destrieux.ctab = 'aparc.annot.a2009s';
    schemes.destrieux.name = 'Destrieux';
    schemes.destrieux.description = 'Destrieux parcellation (76 labels)';
    schemes.destrieux.reference = 'Destrieux et al., 2010, NeuroImage';
    schemes.destrieux.id = '76';
    
    % DKT Atlas (Desikan-Killiany-Tourville)
    schemes.dkt.labels = 40;
    schemes.dkt.annotation = 'aparc.DKTatlas';
    schemes.dkt.ctab = 'DKTatlas40.gcs';
    schemes.dkt.name = 'DKT';
    schemes.dkt.description = 'DKT parcellation (40 labels)';
    schemes.dkt.reference = 'Klein & Tourville, 2012, Frontiers in Neuroscience';
    schemes.dkt.id = 'dkt';
    
    % Mapping from common IDs to scheme names
    schemes.id_map = struct(...
        'x36', 'desikan_killiany', ...
        'x76', 'destrieux', ...
        'dkt', 'dkt' ...
    );
    
end % function
