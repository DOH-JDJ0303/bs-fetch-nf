# nf-core/bsfetch: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0dev - [date]

Initial release of nf-core/bsfetch, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- `MERGE_LANES` module: per-lane FASTQs are concatenated (in lane order) into one file per read direction per sample (`<sample>_R1_001.fastq.gz`, `<sample>_R2_001.fastq.gz`).

### `Fixed`

- `BS_FETCH_BIOSAMPLE` now reads `bs content biosample --format yaml` and keeps the newest file (by `DateCreated`) for each lane + read, instead of only the first two files, so multi-lane samples are fetched completely and re-sequenced lanes replace older ones.
- Biosample name was missing from `bs-contents.csv` and the IDs were written to the wrong file name.
- Malformed `versions.yml` heredocs that broke `CUSTOM_DUMPSOFTWAREVERSIONS`.

### `Dependencies`

### `Deprecated`
