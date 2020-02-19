# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
[2020.2] - 2020-??-??

### Added

### Changed

### Removed

### Fixed

## [2020.1] - 2020-02-??

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

### Fixed
* SeMaWi, in general, has been fixed...
