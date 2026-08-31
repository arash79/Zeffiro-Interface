function key = precompute_cache_key(L, params)
%precompute_cache_key  Fingerprint identifying a cached precomputed operator.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   key = inverse.precompute_cache_key(L, params)
%
%   Inverters whose precompute caches an operator built from the lead field
%   and from solver settings must record the inputs that operator depends on.
%   invert compares the stored key against a freshly built one and discards
%   the cache on any mismatch, so a settings change between precompute and
%   invert can never silently reuse an operator built for other settings.
%
%   Inputs
%     L      - lead field the operator was built from.
%     params - cell array of every property value the cached operator
%              depends on (method switches, regularization parameters,
%              covariance matrices, orientation index sets, ...). Order
%              matters; it only has to be consistent between the precompute
%              and invert call sites of one class.
%
%   Output
%     key    - struct comparable with isequaln. Empty L yields an empty key,
%              which never validates.
%
%   For an in-memory lead field the fingerprint is keyHash(L), which is exact
%   for practical purposes. A gpuArray lead field is fingerprinted by its size
%   and first two moments instead, so that the guard does not force a gather
%   of a large device array; that path can in principle miss a change which
%   preserves both moments.
%
%   See also inverse.CSMInverter, inverse.MNEInverter,
%   inverse.BeamformerInverter, inverse.DipoleScanInverter,
%   inverse.ELORETAInverter.

arguments
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    params cell = {}
end

if isempty(L)
    key = struct([]);
    return
end

key = struct( ...
    'L_size', size(L), ...
    'L_hash', i_leadfield_hash(L), ...
    'params', {params});

end

function h = i_leadfield_hash(L)

if isa(L, 'gpuArray')
    h = keyHash(gather([sum(L(:)), sum(L(:).^2)]));
else
    h = keyHash(L);
end

end
