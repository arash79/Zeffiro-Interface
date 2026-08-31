function zef_GMM_export(save_file_path,GMM,saved_ones)
%ZEF_GMM_EXPORT  uiputfile *.mat of selected GMM fields (ExportButton).
%
%   Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_GMM_export(save_file_path, GMM, saved_ones)
%
%   Called from zef_GMMExport_start ExportButton. saved_ones is six
%   logicals: model, dipoles, amplitudes, time_variables, parameters,
%   reconstruction (from base zef.reconstruction). Writes zef_GMM in the
%   chosen .mat (-v7.3). Does not modify zef.GMM.apps.
%
%   See also zef_GMMExport_start, zef_load_GMM.

if not(isempty(save_file_path)) && prod(not(save_file_path==0))
    [zef_aux_file,zef_aux_path] = uiputfile('*.mat','Select Gaussian Mixture Model',save_file_path);
else
    [zef_aux_file,zef_aux_path] = uiputfile('*.mat','Save Gaussian Mixture Model');
end

if ~isequal(zef_aux_file,0) && ~isequal(zef_aux_path,0)
    if saved_ones{1} == 1
        zef_GMM.model = GMM.model;
    end
    if saved_ones{2} == 1
        zef_GMM.dipoles = GMM.dipoles;
    end
    if saved_ones{3} == 1
        zef_GMM.amplitudes = GMM.amplitudes;
    end
    if saved_ones{4} == 1
        zef_GMM.time_variables = GMM.time_variables;
    end
    if saved_ones{5} == 1
        zef_GMM.parameters = GMM.parameters;
    end
    if saved_ones{6} == 1
        zef_GMM.reconstruction = evalin('base','zef.reconstruction');
    end

    save(fullfile(zef_aux_path,zef_aux_file),'zef_GMM','-v7.3');
end

end
