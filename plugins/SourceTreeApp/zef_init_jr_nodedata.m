function nd = zef_init_jr_nodedata()
%ZEF_INIT_JR_NODEDATA  Default NodeData for a Jansen–Rit source-tree node.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   nd = zef_init_jr_nodedata()
%
%   Name/Value structs consumed by zef_simulate_jr_tree and the Source tree
%   parameter table. OutputGain is in dB (0 dB → linear gain 1).
%
%   See also zef_simulate_jr_tree, zef_start_source_tree_tool.

    nd = struct();

    nd.Model = struct('Name','Model','Value','JansenRit');

    nd.OutputGain    = struct('Name','Output gain (dB)','Value',0);
    nd.SourcePosition    = struct('Name','Position','Value',[0 0 0]);
    nd.SourceOrientation = struct('Name','Orientation','Value',[1 0 0]);
    nd.SourceNoiseStd       = struct('Name','Noise STD','Value',0);

    %% Jansen–Rit parameters (descriptive, no legacy aliases)
    nd.ModelParameters = struct( ...
        ... % Synaptic gains / time constants
        'excSynapticGain_mV',        nv('Exc synaptic gain (mV)', 3.25), ...
        'inhSynapticGain_mV',        nv('Inh synaptic gain (mV)', 22.0), ...
        'excRateConstant_inv_s',     nv('Exc rate constant (1/s)', 50), ...
        'inhRateConstant_inv_s',     nv('Inh rate constant (1/s)', 75), ...
        ... % Coupling gains
        'gain_pyr_to_exc',           nv('Pyr→Exc gain', 135), ...
        'gain_pyr_to_inh',           nv('Pyr→Inh gain', 33.75), ...
        'gain_exc_to_pyr',           nv('Exc→Pyr gain', 108), ...
        'gain_inh_to_pyr',           nv('Inh→Pyr gain', 27), ...
        ... % Sigmoid / firing-rate mapping
        'maxFiringRate_Hz',          nv('Max firing rate (Hz)', 2.5), ...
        'firingThreshold_mV',        nv('Firing threshold (mV)', 6), ...
        'firingSlope_per_mV',        nv('Firing slope (1/mV)', 0.56) );

    %% Delay
    nd.Delay = struct('Delay_s', nv('Delay_s', 0.0));

    %% Connectivity
    nd.Connectivity = struct( ...
        'ToChildren',  nv('ToChildren', 1), ...
        'ToRoots',     nv('ToRoots',    0), ...
        'RootTargets', nv('RootTargets','') );
end

function s = nv(name, value)
    s = struct('Name', name, 'Value', value);
end
