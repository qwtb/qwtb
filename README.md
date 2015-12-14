![QWTB logo](qwtb_doc/logo/qwtb_logo.png?raw=true "QWTB logo")
# Quantum Wave Tool Box (QWTB)

QWTB is a toolbox for evaluation of sampled data. QWTB consist of data processing algorithms from
very different sources and unifying application interface.

The toolbox gives the possibility to use different data processing algorithms with one
set of data and removes the need to reformat data for every particular algorithm. Toolbox is
extensible. The toolbox can variate input data and calculate uncertainties by means of Monte Carlo
Method (MCM).

Toolbox does not require to modify source code of Algorithms, it adapts.

Typical use case: you make a sampling and you want to: get frequency spectra, calculate amplitude
and phase of main sine signal and calculate Allan deviation. But you do not want to search algorithms,
to learn how to use these algorithms and to reformat variables for every one algorithm. Solution? QWTB!

## Toolbox removes:
- a need to find algorithm sources,
- a need to learn how to use algorithms,
- a need to reformat your data in variables to fit oher algorithm.

## Toolbox has:
- standardized format of (input/output) quantities independent on the required algorithm,
- standardized application of algorithms,
- ability to variate inputs and calculate uncertainties by means of Monte Carlo Method.
- examples for every implemented algorithm,
- full documentation with examples,
- tests for every implemented algorithm.

## Toolbox is:
- easy to use,
- open source,
- extensible.
