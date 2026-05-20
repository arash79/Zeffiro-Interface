# ELORETAInverter

`inverse.ELORETAInverter` implements exact low-resolution electromagnetic
tomography (eLORETA) as a class-based inverse method.

Core formulation:

- `M = L*W^{-1}*L' + alpha*H`
- `T = W^{-1}*L'*M^{-1}`
- `z = T*f`

where `W` is found by fixed-point updates from source-wise covariance
blocks and `H` is the average-reference centering matrix (optional).

Main references:

- Pascual-Marqui, R. D. (2007). Discrete, 3D distributed, linear imaging
  methods of electric neuronal activity. arXiv:0710.3341.
- Pascual-Marqui, R. D. (2011). The solution space of the EEG inverse
  problem for 3D distributed linear imaging methods. Philosophical
  Transactions of the Royal Society A, 369(1952), 3768-3784.
