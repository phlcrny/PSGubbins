# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project (tries to) adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 01/11/2020

### Changed

- ``Get-CCMLog`` - removed and spun-off to its own module: [CCMLog](https://github.com/phlcrny/CCMLogs)
- ``New-Password`` - increased/improved dictionaries

## [0.3.0] - 04/06/2020

### Changed

- ``Get-CCMLog`` - Add ``-Path`` parameter.
- ``Get-CCMLog`` - Remove ``-Count`` parameter.
- ``Get-CCMLog`` - Increase lines read from each log file.
- ``Get-CCMLog`` - Add ``-Name`` parameter alias for ``-LogName``
- ``Get-CCMLog`` - Replace ``-All`` parameter alias for ``-AllMessages`` with ``-NoPattern``

## [0.2.0] - 03/06/2020

### Added

- ``Get-CCMLog`` - utility to review multiple CCM logs/entries as objects.

## [0.1.0] - 10/04/2020

### Added

- ``Get-Cpl`` or ``Get-ControlPanelApplet`` - helper function for identifying Control Panel applets
- ``Get-Msc`` or ``Get-MMCSnapIn`` - helper function for identifying MMC snap-ins
- ``New-Password`` or ``New-Passphrase`` - a function to generate passphrases or passwords
- ``New-RdpSession`` or ``rdp`` -  a helper function start RDP sessions from Powershell
