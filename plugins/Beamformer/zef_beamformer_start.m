function zef = zef_beamformer_start(zef)
%ZEF_BEAMFORMER_START  Entry point that opens the Beamformer plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_beamformer_start
%   zef = zef_beamformer_start(zef)
%
%   INI callback (Inverse tools → Beamformer). Opens the beamformer app via
%   zef_beamformer_window. StartButton runs zef_beamformer(zef); which
%   output is stored as reconstruction depends on estimation_attr.
%   Needs zef.L and zef.measurements. Does not call inverse.BeamformerInverter.
%
%   See also zef_beamformer_window, zef_beamformer.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_beamformer_window',1/4,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
