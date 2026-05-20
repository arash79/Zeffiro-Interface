function mappings = compartment_mappings()
%
% compartment_mappings - Tissue-specific parameters and mappings
%
% Returns a struct with default parameters for different tissue/compartment types.
% Used by generate_zef_import to assign appropriate sigma, activity, and other
% parameters based on compartment names.
%
% Outputs:
%   mappings - Struct with compartment configurations
%

    mappings = struct();
    
    % === Cortical Tissues ===
    
    mappings.grey_matter.sigma = 0.33;
    mappings.grey_matter.activity = 1;
    mappings.grey_matter.inflate = 0;
    mappings.grey_matter.keywords = {'grey', 'gray', 'cortex', 'pial'};
    
    mappings.white_matter.sigma = 0.14;
    mappings.white_matter.activity = 3;
    mappings.white_matter.inflate = 0;
    mappings.white_matter.keywords = {'white', 'wm'};
    
    % === Fluid Spaces ===
    
    mappings.csf.sigma = 1.79;
    mappings.csf.activity = 0;
    mappings.csf.inflate = 0;
    mappings.csf.keywords = {'csf', 'fluid', 'ventricle'};
    
    % === Skull and Skin ===
    
    mappings.skull.sigma = 0.0064;
    mappings.skull.activity = 0;
    mappings.skull.inflate = 0;
    mappings.skull.keywords = {'skull', 'bone'};
    
    mappings.skin.sigma = 0.33;
    mappings.skin.activity = 0;
    mappings.skin.inflate = 0;
    mappings.skin.keywords = {'skin', 'scalp'};
    
    % === Subcortical Grey Matter ===
    
    mappings.subcortical_grey.sigma = 0.33;
    mappings.subcortical_grey.activity = 2;
    mappings.subcortical_grey.inflate = 0;
    mappings.subcortical_grey.keywords = {...
        'thalamus', 'caudate', 'putamen', 'pallidum', 'globus', ...
        'hippocampus', 'amygdala', 'accumbens', 'nucleus'};
    
    % === Cerebellum ===
    
    mappings.cerebellum_cortex.sigma = 0.33;
    mappings.cerebellum_cortex.activity = 2;
    mappings.cerebellum_cortex.inflate = 0;
    mappings.cerebellum_cortex.keywords = {'cerebellum-cortex'};
    
    mappings.cerebellum_wm.sigma = 0.14;
    mappings.cerebellum_wm.activity = 0;
    mappings.cerebellum_wm.inflate = 0;
    mappings.cerebellum_wm.keywords = {'cerebellum-white'};
    
    % === Brainstem ===
    
    mappings.brainstem.sigma = 0.33;
    mappings.brainstem.activity = 2;
    mappings.brainstem.inflate = 0;
    mappings.brainstem.keywords = {'brainstem', 'brain-stem'};
    
    % === Other ===
    
    mappings.ventral_dc.sigma = 0.33;
    mappings.ventral_dc.activity = 2;
    mappings.ventral_dc.inflate = 0;
    mappings.ventral_dc.keywords = {'ventraldc'};
    
    mappings.corpus_callosum.sigma = 0.14;
    mappings.corpus_callosum.activity = 0;
    mappings.corpus_callosum.inflate = 0;
    mappings.corpus_callosum.keywords = {'cc_', 'corpus-callosum'};
    
    % === Default (fallback) ===
    
    mappings.default.sigma = 0.33;
    mappings.default.activity = 0;
    mappings.default.inflate = 100;
    mappings.default.keywords = {};
    
end % function
