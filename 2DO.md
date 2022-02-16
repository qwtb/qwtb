# 2DO
## validation
algorihm can contain `alg_valid.m`. running this the validation will be provided
validation.
- validation calculates errors and uncertainties for various inputs,
- test tests the algorithm if it works correctly

## valid ranges
range of intput quantities will be defined in which algorithm was validated - result of validation

## fast uncertainty estimation (FUE)
in the range, a table for interpolation - result of validation

Validation scheme:

- defined ranges
- set points in ranges for which validation will be done
- prepare multicore calculation:
    - for IQ, get OQ
    - idealize OQ
    - construct IQ` <- inputs to calculation
- start calculation, consists of:
    - for IQ`, calculate OQ`
    - compare OQ` to idealized OQ
- concatenate results
- print out report
- save results for FUE
- report on valid ranges
- update valid ranges

## source
algorithm can contain directory `source` with source of the algorithm, if available

## algorithm documentation
- algorithm should contain directory `doc` with documentation in latex format `alg_doc.tex`
- highest section level will be subsection
- qwtb can run compilation, that will compile all `alg_doc.tex` in all algorithms as standalone and joined:

### standalone documentation compilation
- qwtb will add first/last pages
- first pages will contain:
    1. algorithm info same as in actual `QWTB-Alg_doc.pdf`
    1. requirements for other algorithms?
- in the middle will be the `alg_doc.tex`
- next are examples from `alg_example.m`
- last pages will contain:
    1. date and checksum of commpilation, files, qwtb version, git state, etc
    1. link to qwtb, github etc.

### joined documentation compilation
- qwtb will make the `QWTB-Tb_doc.pdf` as usual
