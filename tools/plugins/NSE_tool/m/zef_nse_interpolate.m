function zef = zef_nse_interpolate(zef,type)
%ZEF_NSE_INTERPOLATE  Interpolate button: source flags from reconstruction_type then zef_source_interpolation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_interpolate. reconstruction_type_list{1} (artery
%   types) turns on artery-domain _sources and sets source_positions to
%   bp_vessel nodes; list{2} (microcirculation types) uses capillary
%   domains / bf_capillary nodes. Then zef_source_interpolation.
%
%   zef = zef_nse_interpolate(zef, type)
%
%   See also zef_source_interpolation, zef_nse_reconstruction.
%

if ismember(type,zef.nse_field.reconstruction_type_list{1})

    for i = 1 : length(zef.compartment_tags)
        eval(['zef.' zef.compartment_tags{i} '_sources = 0;'])
    end


    for i = 1 : length(zef.nse_field.artery_domain_ind)
        eval(['zef.' zef.compartment_tags{zef.nse_field.artery_domain_ind(i)} '_sources = 1;'])
    end

    zef = zef_build_compartment_table(zef);

    zef.active_compartment_ind = find(ismember(zef.domain_labels,zef.nse_field.artery_domain_ind));
    zef.source_positions = zef.nodes(zef.nse_field.bp_vessel_node_ind,:);

elseif ismember(type,zef.nse_field.reconstruction_type_list{2})

    for i = 1 : length(zef.compartment_tags)
        eval(['zef.' zef.compartment_tags{i} '_sources = 0;'])
    end


    for i = 1 : length(zef.nse_field.capillary_domain_ind)
        eval(['zef.' zef.compartment_tags{zef.nse_field.capillary_domain_ind(i)} '_sources = 1;'])
    end

    zef = zef_build_compartment_table(zef);

    zef.active_compartment_ind = find(ismember(zef.domain_labels,zef.nse_field.capillary_domain_ind));
    zef.source_positions = zef.nodes(zef.nse_field.bf_capillary_node_ind,:);

end

zef = zef_source_interpolation(zef);

end
