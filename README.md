# ShufflePaper v0.5
by Bujiraso, licensed under GPLv3 or later (see COPYING)

## Requirements
* bash (version 3 or higher)
* sqlite3

###### Optional Requirements
* cronie

## Description
ShufflePaper builds a wallpaper database from a folder of images and is capable of randomly selecting your desktop wallpaper and managing metadata about your wallpapers.

The default wallpaper location is `$HOME/Pictures/Wallpapers` and can be changed within the shufflepaper.conf in the conf directory

## Installation & First Set up
* Download the project (extract if necessary)
* Run `$ make.sh INSTALL_DIR` to a directory on your path
* Ensure `$XDG_DATA_DIR` and `$XDG_CONFIG_HOME` are set
* Run $ sfp init-db
* Set wallpaper location in `$XDG_CONFIG_HOME/shufflepaper.conf` and optionally tweak query settings in user.conf
* Run $ sfp miner to collect all wallpapers. This is currently dramatically slow -- to be optimized later.
* Call '$ sfp random' when a new background is desired. You can add this to your cron as described below

### Cron Usage

To have ShufflePaper select a background for you on a regular interval, use a cron service like cronie and add a line like this to your crontab

```bash
# Change background every ten minutes
*/10 * * * * fully/qualified/install/location/sfp random
```

## Usage
Run `sfp` to see what commands are available.
