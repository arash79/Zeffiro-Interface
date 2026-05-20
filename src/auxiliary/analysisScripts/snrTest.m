% --- Zeffiro documentation header ---
% if ~strcmp(zef.dataBank.app.Entrytype — If ~strcmp(zef.data Bank.app.Entrytype.
%
% Purpose:
%   If ~strcmp(zef.data Bank.app.Entrytype.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Zef fields (observed):
%   zef.inv_prior_over_measurement_db (read, write)
%   zef.inv_snr (read, write)
%   zef.ramus_snr (read, write)
%   zef.reconstruction (read)
%   zef.reconstruction_information (read)
%
% Calls (project):
%   zef_ramus_iteration
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if ~strcmp(zef.dataBank.app.Entrytype` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if ~strcmp(zef.dataBank.app.Entrytype.Value, 'reconstruction')
    error('wrong type');
else

    datetime

    for mmm=[3,1,2]

        for psnr=([-50 -40-30 -20 -10 -5 0 5 10 15 20 30 40 50 6070 80 90])

            zef.inv_prior_over_measurement_db=psnr;

            for snr=-40:10:50

                zef.inv_snr=snr;
                zef.ramus_snr=snr;

                switch mmm
                    case 1

                        [zef.reconstruction, zef.reconstruction_information]=zef_find_mne_reconstruction;
                        zef_dataBank_addButtonPress;

                    case 2
                        %sLoreta

                        [zef.reconstruction, zef.reconstruction_information]=zef_CSM_iteration;
                        zef_dataBank_addButtonPress;

                    case 3
                        %ramus
                        [zef.reconstruction, zef.reconstruction_information]  = zef_ramus_iteration([]);
                        zef_dataBank_addButtonPress;
                end
            end
        end
    end
    datetime
end
