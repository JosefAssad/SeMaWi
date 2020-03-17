# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
[2020.2] - 2020-??-??

### Added

### Changed

### Removed

### Fixed

## [2020.1RC2] - 2020-03-20

### Added

### Changed

### Removed
* GeoCloud 2 synchronisation microservice has been removed as agreed with BALK
  to facilitate the migration to a Linode.
* ODBC integration has been deprecated and removed as SeMaWi will focus in the
  coming period on cross-municipal models rather than deeper portfolio
  integration.

### Fixed

## [2020.1RC1] - 2020-02-29

This is an update, refresh, and refactoring release.

### Added
* Transition to an initial draft microservices architecture.

### Changed
* Mediawiki distribution construction is moved into the Docker image
* The php memory limit is made configurable
* Dependency versions are also specifiable in the config now
* GNU Make is now used to ease some of the backend administration tasks
* A new microservice is added which allows us to trigger non-networked Mediawiki
  tasks such as `update.php` with http calls
* A cron container has been introduced to trigger Geocloud 2 syncs and
  `runJobs.php` calls, obviating the need for host-based cronjobs.
* Docker containers now have (rudimentary) health checks
* We can toggle the Mediawiki error facilities from the configuration now.
* SeMaWi has had almost all of its dependencies updated to latest stable. A
  notable exception is MySQL, since the latest versions appear to be a lot less
  tested and perform extremely slowly with Mediawiki.
* GeoCloud synchronisation is now split out in its own microservice.
* SeMaWi now uses its own MySQL container instead of one provided by the docker
  host.
* Debian docker base images are also updated to the latest stable, 10.2.
* php dependency management has been moved over entirely to composer; no more
  pear errors.

### Fixed
* SeMaWi, in general, has been fixed...

### Notes
* We remain on MySQL 5.7. This is far behind what is current, but the current
  version in my testing performed abysmally and seemed to cause data issues.
  Worth investigating.
* We hope to upgrade to 1.34 but have tested and encountered some problems
  porting data. so for now, MediaWiki 1.31 will do fine as it is the current
  LTS release.
