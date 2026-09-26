<h1 align="center">CSDStudio</h1>

<p align="center">
  <a href="https://doi.org/10.5281/zenodo.20513437">
    <img src="https://img.shields.io/badge/DOI-10.5281%2Fzenodo.20513437-blue?style=for-the-badge" alt="DOI">
  </a>
</p>

<p align="center">
  CSDStudio: A MATLAB app for modeling curved CSDs produced by magma mixing
  NOTE: Software still in development. Expected final release for macOS and windows ~Sept. 2026. 
</p>



## Version history

### CSDStudio 2026b

CSDStudio 2026b introduces substantial updates to model initialization, nonlinear inversion, MCMC sampling, uncertainty visualization, and data export. The Linear, Growth-Law, two-magma reservoir, and three-magma reservoir CSD models remain available.
Minor bugs fixes present in CSDStudio 2026a. 

**Model and parameter updates**
- Renamed 2-Chamber and 3-Chamber models to 2-Reservoir and 3-Reservoir, respectively.
- Renamed mixing weights `alpha1` and `alpha2` to `w1` and `w2`.
- Added the option to fix `ln(n_mix^0)` during two- and three-reservoir inversion.

**Initialization and inversion**
- Revised automatic piecewise initialization and breakpoint selection.
- Made automatic initialization the default. Fixed minor bugs for manual piecewise initialization

**MCMC**
- Introduced adaptive, covariance-informed proposals during burn-in.
- Added a stochastic initialization procedure for automatic MCMC runs.
- Expanded acceptance-rate and sampling diagnostics.

**Visualization and uncertainty**
- Added a mode displaying the MCMC best-fit and posterior-mean curves together.
- Added independent marker and fit-line visibility controls, improved sample styling, and square-axis pop-out plots.

**Results and export**
- Added Excel export of plot-ready data for model fits, residuals, initialization data, and applicable MCMC traces and posterior samples.
- Expanded results metadata to include mean crystal size, reservoir weights, initialization method, MCMC settings, and software version.
- Updated parameter summaries to report 95% interval bounds.


