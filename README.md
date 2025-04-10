# JPass

## Overview

JPass is a Swift CLI tool that makes managing [Jamf Pro's LAPS (Local Administrator Password Solution)](https://www.jamf.com/blog/jamf-pro-laps-manage-local-admin-passwords/) fast, secure, and scriptable - simplifying the adoption and management of LAPS. This allows administrators to quickly view, set, and rotate local admin passwords without needing to navigate the Jamf Pro web interface for common tasks.

## Key Features
### 🆔 Flexible Identifier Lookups

Perform lookups using one of several supported identifiers: **Jamf Id, computer name, management id, asset tag, bar code, or serial number**. If multiple results are returned, admins are prompted to select a specific host before proceeding.

### ↩️ Quick & Convenient Password Retrieval

Quickly and easily retrieve the LAPS password for a given host with flags to copy the password directly to your clipboard
or to be printed in a NATO phonetic format for clear verbal communication.

### 👶🏻 Simple Password Rotations

Securely trigger password rotations quickly without exposing the current password.

### 🛠️ Flexible Password Setting (Manual, Programmatic, Generated)

Set LAPS passwords by either manually providing a password, piping one in via STDIN from your favorite password generator, or by generating it using a built-in passphrase generator capable of creating over **_48 Billion_** unique phrases ranging from 14 to 29 characters long in the format `<adverb>-<verb>-<noun>` (e.g. radically-baffled-hero, obviously-panicked-volume)

### 🔍 Investigate LAPS usage via History and Audit Trails

Easily view the history of all viewed or rotated passwords for a host or dig a bit deeper by peeking at its audit trail. 
Notice an API client was the culprit but not sure which one the id maps to? JPass provides convenience flags to quickly
map all API client IDs to their respective display name. No more poking around the JPS GUI to figure out whodunit.

### 🖥️ Monitor Pending Rotations

See all pending password rotations with timestamps of the event alongside which computer and LAPS user it applies to. Management IDs
mean nothing to you? Pass a convenience flag to map management ids to their respective computer name.

### ⚙️ Easy Jamf Pro LAPS Configuration

Take the friction out of viewing or configuring your Jamf Pro's LAPS settings. See time values in human-readable format (who knows how many
days 7776000 seconds is off hand...) or quickly toggle settings - all modifications prompt for confirmation unless explicitly given via a flag. 

### 🔐 Secure Credential Caching (macOS Keychain)

Once successfully authenticated, JPass securely caches credentials in your local keychain on a per-user, per-server, per-port basis (here's lookin' at you MSPs 👋) - or don't by explicitly disabling credential caching. Want to remove a specific cached value? JPass caches credentials with human-readable labels in your local keychain. 
Simply open **Keychain Access**, select the **login** keychain, search for **JPass**, and delete the offending records.

### 👥 Support For Jamf Pro Users & API Clients Alike

Supports using either a Jamf Pro user or an API client, supporting credential caching for both.

### 👮🏻 Security-Focused Design

All displayed passwords trigger rotations, all communications happen over HTTPS, JPass triggered rotations utilize HEAD requests (requests only headers to be sent back, meaning the password never leaves the JPS), credentials cached in the local macOS keychain (no iCloud syncing here folks), cached credentials get destroyed upon recieving an unathorized response, and more. All design decisions are made with security in mind. 

## Requirements
- **Operating System**: macOS 14.6 or higher
- **Jamf Pro**: 10.46.0 or higher

## Installation
While Swift supports all major operating systems, JPass currently only supports macOS since it leverages macOS-specific APIs to access the local keychain. This may change in the future if there's enough demand.

JPass is a self-contained binary so it can be installed anywhere. The recommended method is:
1. Download the [latest release](https://github.com/manicmachine/jpass/releases/latest)
2. Move it to `/usr/local/bin/` 
     - JPass can be installed anywhere, but this path is included in your environment by default
3. Set it as executable by running `chmod +x /usr/local/bin/jpass`

Now you can run `jpass` from anywhere in your favorite shell.

## Configuration
JPass supports the following (optional) environment variables:
- `JPASS_SERVER`: Configures the Jamf Pro Server address to be used for all queries.
  - Specifying the scheme (https://) and port are optional. By default, JPass uses port `443` for jamf cloud instances and `8443` otherwise. If you don't use a standard port, specify your own by appending `:<port>` to the end of the URL (e.g. your.jps.url:9090)
  - Can be overriden with the `--server|-s` options
- `JPASS_USER`: Configures the Jamf Pro User to be used for all queries
  - Can be overriden with the `--user|-u` options.
  - Cannot be used at the same time as `JPASS_CLIENT_ID`
- `JPASS_CLIENT_ID`: Configures the Jamf Pro API Client to be used for all queries
  - Can be overriden with the `--client-id` option
  - Cannot be used at the same time as `JPASS_USER`
- `JPASS_LOCAL_ADMIN`: Configures the local admin account for all queries
  - Can be overriden with the `--ladmin|-l` options
- `JPASS_NO_CACHE`: Disables credential caching
  - Equivalent to the `--no-cache` option
  - The value is irrelevant, as long as it's set

To easily configure these values, you can run `export <variable>='<value>'` in your shell. 
Example: `export JPASS_SERVER='your.jps.url'`. 

To persist these changes between sessions, add your export statements to your shell's rc file (~/.zshrc by default). You can either
manually edit the file with your favorite text editor, or run `echo "export <variable>='<value>'" >> ~/.zshrc`. Note that you'll need to start a new shell or run `source ~/.zshrc` for changes to take effect.

Example: `echo "export JPASS_SERVER='your.jps.url'" >> ~/.zshrc`

## Basic Usage
All examples assume the above JPass environment variables have been configured. If not, add the options `--server|-s <server>` and `--user|-u <user>` to each command. 

For expanded/detailed usage, all commands support the `--help|-h` flag. Alternatively, you can use `jpass help <command>`. 

All subcommands support aliases to reduce the number of keystrokes (typing is hard, I know), such as `pen` and `p` for `pending`. All aliases can be viewed by checking the help text. 

**NOTE: `<identifier>` can be one of the following: Jamf Id, computer name, management id, asset tag, bar code, or serial number. If multiple results are returned, admins are prompted to select a specific host before proceeding.**
- **Retrieve a LAPS password**:
  ```bash
  jpass get <identifier> [--nato|-n] [--copy|-c]
  ```
  `get` is the default command, so this can be reduced to `jpass <identifier>`.
  
  If `--nato|-n` is provided, the retrieved password will be printed to STDOUT in addition along with a NATO phonetic pronunciation guide.
  
  If `--copy|-c` is provided, the retrieved password will be copied directly to your clipboard instead of being printed to STDOUT.
- **Rotate LAPS password**:
  ```bash
  jpass rotate <identifier> ...
  ```
- **Set a LAPS password**:
  ```bash
  jpass set <identifier> ... [--pass|-p <password>] [--generate|-g]
  ```
  Using `--pass|-p` is optional. If not provided, JPass will prompt for the new password. 

  **⚠️ If multiple identifiers are provided while explicitly setting the password, each device will be assigned the same password.** The intent here is to allow admins to set a predefined password across multiple computers for extended periods of work before being manually rotated upon completion.

- **Set a LAPS password to a random passphrase**:
  ```bash
  jpass set <identifier> ... [--generate|-g]
  ```
    Using the `--generate|-g` option will result in JPass assigning a random 14-29 character 3-word phrase for the password in the format `<adverb>-<verb>-<noun>`, e.g. radically-baffled-hero. 
- **List LAPS accounts for a host**:
  ```bash
  jpass accounts <identifier>
  ```
- **View audit trail. Includes past passwords, who viewed it, when it was viewed, and when it expired**:
  ```bash
  jpass audit <identifier> [--map-client|-m]
  ```
- **View LAPS history. Includes date created, date last seen, expiration time, and rotational status**
  ```bash
  jpass history <identifier> [--map-client|-m]
  ```
- **View pending rotations**
  ```bash
  jpass pending [identifier ...] [--map-computers|-m]
  ```
  If one or more `identifier`s are provided, pending results will be filtered down to those hosts.

  If `--map-computers|-m` is provided, returned management Ids will be mapped to their respective computer names.
- **View global LAPS configuration**
  ```bash
  jpass config get
  ```
- **Modify global LAPS configuration**
  ```bash
  jpass config set [--enable-auto-deploy|--disable-auto-deploy] [--enable-auto-rotate|--disable-auto-rotate] [--password-rotation-time <password-rotation-time>] [--auto-rotate-expiration-time <auto-rotate-expiration-time>] [--confirm]
  ```
  If `--confirm` isn't provided, JPass will validate the requested changes and prompt for confirmation before proceeding.


## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## Created By

Written by Corey Oliphant: A Jamf System Administrator and former Jamf Software Engineer/Technical Support Engineer.

## License
MIT License

Copyright (c) 2024 Corey Oliphant

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
