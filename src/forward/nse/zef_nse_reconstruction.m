function [reconstruction, reconstruction_info] = zef_nse_reconstruction(nse_field,type)
%ZEF_NSE_RECONSTRUCTION  Pack NSE vessel fields into inverse-style reconstruction cells.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   type matches NSE tool h_reconstruction_type.ItemsData (1…17):
%     1  Pressure (Arteries) — bp_vessels, one cell per frame
%     2  Velocity (Arteries) — bv_vessels_1/2/3
%     3  Viscosity (Arteries) — mu_vessels
%     4  Concentration (Microcirculation) — bf_capillaries
%     5  Deoxygenized hemoglobin concentration — dh_capillaries
%     6–8   Mean / max / STD pressure (collapsed to reconstruction{1})
%     9–11  Mean / max / STD velocity
%    12–14  Mean / max / STD viscosity
%    15–17  Mean / max / STD concentration (values clamped to [0,1])
%   Types 1–5 keep one reconstruction cell per NSE frame. 6–17 collapse time.
%   Each scalar is stored as an xyz triplet /√3 for the Figure-tool colormap.
%   Quantile clip: nse_field.min/max_reconstruction_quantile.
%   Type 8 (STD pressure) assigns aux_vec with a comma expression that does
%   not call zef_nse_threshold_distribution (as written). Type 17 divides
%   the running mean by size(bp_vessels,2) rather than bf_capillaries.
%
%   [reconstruction, reconstruction_info] = zef_nse_reconstruction(nse_field, type)
%
%   See also zef_nse_threshold_distribution, zef_nse_poisson.

reconstruction = cell(0);
reconstruction_info = cell(0);

if isequal(type,1)

    for i = 1 : size(nse_field.bp_vessels,2)

        aux_vec = zef_nse_threshold_distribution(nse_field.bp_vessels{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);
        reconstruction{i} = (1/sqrt(3))*aux_vec(:,[1 1 1])';
        reconstruction{i} = reconstruction{i}(:);

    end

elseif isequal(type,2)

    for i = 1 : size(nse_field.bv_vessels_1,2)
        aux_vec_1 = zef_nse_threshold_distribution(nse_field.bv_vessels_1{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);
        aux_vec_2 = zef_nse_threshold_distribution(nse_field.bv_vessels_2{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);
        aux_vec_3 = zef_nse_threshold_distribution(nse_field.bv_vessels_3{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

        reconstruction{i} = (1/sqrt(3))*[aux_vec_1 aux_vec_2 aux_vec_3]';
        reconstruction{i} = reconstruction{i}(:);

    end

elseif isequal(type,3)

    for i = 1 : size(nse_field.mu_vessels,2)

        aux_vec = zef_nse_threshold_distribution(nse_field.mu_vessels{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

        reconstruction{i} = (1/sqrt(3))*aux_vec(:,[1 1 1])';
        reconstruction{i} = reconstruction{i}(:);

    end

elseif isequal(type,4)
    
    for i = 1 : size(nse_field.bf_capillaries,2)

        aux_vec = zef_nse_threshold_distribution(nse_field.bf_capillaries{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

        reconstruction{i} = (1/sqrt(3))*aux_vec(:,[1 1 1])';
        reconstruction{i} = reconstruction{i}(:);

    end

    elseif isequal(type,5)

    for i = 1 : size(nse_field.dh_capillaries,2)

        aux_vec = zef_nse_threshold_distribution(nse_field.dh_capillaries{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

        reconstruction{i} = (1/sqrt(3))*aux_vec(:,[1 1 1])';
        reconstruction{i} = reconstruction{i}(:);

    end

elseif isequal(type,6)

    reconstruction{1} = zeros(3,size(nse_field.bp_vessels{1}(:),1));

    for i = 1 : size(nse_field.bp_vessels,2)

        aux_vec = nse_field.bp_vessels{i}(:);
        reconstruction{1} = reconstruction{1} + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    reconstruction{1} = reconstruction{1}(:)/size(nse_field.bp_vessels,2);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

elseif isequal(type,7)

    reconstruction{1} = zeros(3,size(nse_field.bp_vessels{1}(:),1));

    for i = 1 : size(nse_field.bp_vessels,2)

        aux_vec = nse_field.bp_vessels{i}(:);
        reconstruction{1} = max(reconstruction{1},(1/sqrt(3))*aux_vec(:,[1 1 1])');

    end

    reconstruction{1} = reconstruction{1}(:);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


elseif isequal(type,8)

    mean_data = zeros(3,size(nse_field.bp_vessels{1}(:),1));

    for i = 1 : size(nse_field.bp_vessels,2)

        % Comma expression: aux_vec is the last operand (the quantile
        % scalar), not thresholded pressure. Documented as written.
        aux_vec = nse_field.bp_vessels{i}(:),nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile;
        mean_data = mean_data + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    mean_data = mean_data/size(nse_field.bp_vessels,2);

    reconstruction{1} = zeros(3,size(nse_field.bp_vessels{1}(:),1));


    for i = 1 : size(nse_field.bp_vessels,2)

        aux_vec = nse_field.bp_vessels{i}(:);
        reconstruction{1}  =  reconstruction{1} + ((1/sqrt(3))*aux_vec(:,[1 1 1])' - mean_data).^2;

    end

    reconstruction{1} = sqrt(reconstruction{1}(:)/size(nse_field.bp_vessels,2));
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


elseif isequal(type,9)

    reconstruction{1} = zeros(3,size(nse_field.bv_vessels_1{1}(:),1));

    for i = 1 : size(nse_field.bv_vessels_1,2)

        aux_vec_1 = nse_field.bv_vessels_1{i}(:);
        aux_vec_2 = nse_field.bv_vessels_2{i}(:);
        aux_vec_3 = nse_field.bv_vessels_3{i}(:);

        reconstruction{1} = reconstruction{1} + (1/sqrt(3))*[aux_vec_1 aux_vec_2 aux_vec_3]';

    end

    reconstruction{1} = reconstruction{1}(:)/size(nse_field.bv_vessels_1,2);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);

elseif isequal(type,10)

    reconstruction{1} = zeros(3,size(nse_field.bv_vessels_1{1}(:),1));

    for i = 1 : size(nse_field.bv_vessels_1,2)

        aux_vec_1 = nse_field.bv_vessels_1{i}(:);
        aux_vec_2 = nse_field.bv_vessels_2{i}(:);
        aux_vec_3 = nse_field.bv_vessels_3{i}(:);

        reconstruction{1} = max(reconstruction{1},(1/sqrt(3))*[aux_vec_1 aux_vec_2 aux_vec_3]');

    end

    reconstruction{1} = reconstruction{1}(:);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);



elseif isequal(type,11)

    mean_data = zeros(3,size(nse_field.bv_vessels_1{1}(:),1));

    for i = 1 : size(nse_field.bv_vessels_1,2)

        aux_vec_1 = nse_field.bv_vessels_1{i}(:);
        aux_vec_2 = nse_field.bv_vessels_2{i}(:);
        aux_vec_3 = nse_field.bv_vessels_3{i}(:);

        mean_data = mean_data + (1/sqrt(3))*[aux_vec_1 aux_vec_2 aux_vec_3]';


    end

    mean_data = mean_data/size(nse_field.bv_vessels_1,2);

    reconstruction{1} = zeros(3,size(nse_field.bv_vessels_1{1}(:),1));
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


    for i = 1 : size(nse_field.bv_vessels_1,2)

        aux_vec = nse_field.bv_vessels_1{i}(:);
        reconstruction{1}  =  reconstruction{1} + ((1/sqrt(3))*aux_vec(:,[1 1 1])' - mean_data).^2;

    end

    reconstruction{1} = sqrt(reconstruction{1}(:)/size(nse_field.bv_vessels_1,2));
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);



elseif isequal(type,12)

    reconstruction{1} = zeros(3,size(nse_field.mu_vessels{1}(:),1));

    for i = 1 : size(nse_field.mu_vessels,2)

        aux_vec = nse_field.mu_vessels{i}(:);
        reconstruction{1} = reconstruction{1} + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    reconstruction{1} = reconstruction{1}(:)/size(nse_field.mu_vessels,2);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


elseif isequal(type,13)

    reconstruction{1} = zeros(3,size(nse_field.mu_vessels{1}(:),1));

    for i = 1 : size(nse_field.mu_vessels,2)

        aux_vec = nse_field.mu_vessels{i}(:);
        reconstruction{1} = max(reconstruction{1}, (1/sqrt(3))*aux_vec(:,[1 1 1])');

    end

    reconstruction{1} = reconstruction{1}(:);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


elseif isequal(type,14)

    mean_data = zeros(3,size(nse_field.mu_vessels{1}(:),1));

    for i = 1 : size(nse_field.mu_vessels,2)

        aux_vec = nse_field.mu_vessels{i}(:);
        mean_data = mean_data + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    mean_data = mean_data/size(nse_field.mu_vessels,2);

    reconstruction{1} = zeros(3,size(nse_field.mu_vessels{1}(:),1));
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


    for i = 1 : size(nse_field.mu_vessels,2)

        aux_vec = nse_field.mu_vessels{i}(:);
        reconstruction{1}  =  reconstruction{1} + ((1/sqrt(3))*aux_vec(:,[1 1 1])' - mean_data).^2;

    end

    reconstruction{1} = sqrt(reconstruction{1}(:)/size(nse_field.mu_vessels,2));

elseif isequal(type,15)

    reconstruction{1} = zeros(3,size(nse_field.bf_capillaries{1}(:),1));

    for i = 1 : size(nse_field.bf_capillaries,2)

        aux_vec = min(max(0,abs(nse_field.bf_capillaries{i}(:))),1);
        reconstruction{1} = reconstruction{1} + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    reconstruction{1} = reconstruction{1}(:)/size(nse_field.bf_capillaries,2);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);



elseif isequal(type,16)

    reconstruction{1} = zeros(3,size(nse_field.bf_capillaries{1}(:),1));

    for i = 1 : size(nse_field.bf_capillaries,2)

        aux_vec = min(max(0,abs(nse_field.bf_capillaries{i}(:))),1);
        reconstruction{1} = max(reconstruction{1},(1/sqrt(3))*aux_vec(:,[1 1 1])');

    end

    reconstruction{1} = reconstruction{1}(:);
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);


elseif isequal(type,17)

    mean_data = zeros(3,size(nse_field.bf_capillaries{1}(:),1));

    for i = 1 : size(nse_field.bf_capillaries,2)

        aux_vec = min(max(0,abs(nse_field.bf_capillaries{i}(:))),1);
        mean_data = mean_data + (1/sqrt(3))*aux_vec(:,[1 1 1])';

    end

    % Type 17 STD concentration: mean is divided by size(bp_vessels,2),
    % not bf_capillaries, even though the loop is over capillary frames.
    mean_data = mean_data/size(nse_field.bp_vessels,2);

    reconstruction{1} = zeros(3,size(nse_field.bf_capillaries{1}(:),1));

    for i = 1 : size(nse_field.bf_capillaries,2)

        aux_vec = min(max(0,abs(nse_field.bf_capillaries{i}(:))),1);
        reconstruction{1}  =  reconstruction{1} + ((1/sqrt(3))*aux_vec(:,[1 1 1])' - mean_data).^2;

    end

    reconstruction{1} = sqrt(reconstruction{1}(:)/size(nse_field.bf_capillaries,2));
    reconstruction{1} = zef_nse_threshold_distribution(reconstruction{1},nse_field.min_reconstruction_quantile,nse_field.max_reconstruction_quantile);




end


end
