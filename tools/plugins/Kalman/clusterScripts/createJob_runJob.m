% --- Zeffiro documentation header ---
% warning('plugins.Kalman.clusterScripts:Deprecated', ... — Warning('plugins.Kalman.cluster Scripts:Deprecated', .
%
% Purpose:
%   Warning('plugins.Kalman.cluster Scripts:Deprecated', ....
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `warning('plugins.Kalman.clusterScripts:Deprecated', ...` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

warning('plugins.Kalman.clusterScripts:Deprecated', ...
    ['createJob_runJob is deprecated. Use ', ...
     'utilities.cluster.examples.kalman_workflow instead.']);
