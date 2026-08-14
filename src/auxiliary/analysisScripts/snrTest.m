%SNRTEST  Lab script: MNE/CSM/RAMUS over a grid of inv_snr and prior dB.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Errors unless zef.dataBank.app.Entrytype.Value is
%   'reconstruction'. Nested loops: methods 3,1,2 then psnr list (includes
%   concatenated tokens -40-30 and 6070 as written) and snr -40:10:50.
%   zef_dataBank_addButtonPress after each invert. One-off SNR paper run.
%

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
