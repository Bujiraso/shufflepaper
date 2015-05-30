#ShufflePaper v0.4
by Bujiraso, licensed under GPLv3 or later (see COPYING)

## Requirements
* bash (version 3 or higher)
* sqlite3

###### Optional Requirements
* cronie

##Description
ShufflePaper builds a wallpaper database from a folder of images and is capable of randomsly selecting your desktop wallpaper and managing metadata about your wallpapers.

The default wallpaper location is $HOME/Pictures/Wallpapers and can be changed within the shufflepaper.conf in the conf directory

To have ShufflePaper select a background for you on a regular interval, use a cron service like cronie and add a line like this to your crontab

\# Change background every ten minutes  
\*/10 * * * * fully/qualified/install/location/randomBG.sh

##Installation & Usage
* Download the project (extract if necessary)
* Set wallpaper location in shufflepaper.conf and optionally set XDG_DATA_HOME
* Run install.sh
* Run wallMiner.sh to collect all the wallpapers (performance upgrades are planned for future releases)
* Set up cron to run or manually call randomBG.sh when a new background is desired