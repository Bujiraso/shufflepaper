#ShufflePaper v0.3
by Bujiraso, licensed under GPLv3 or later (see COPYING)

##Description
ShufflePaper randomizes your desktop background from a folder of wallpaper
images

Upon running randomBG.sh, it makes a shuffled list from all the images (files
for now, actually) in a given folder or checks if one exists, once this list
is prepared it takes the first image in the list and sets it as your wallpaper.

For now it is capable of checking if files and directories exist but it is not
capable of selecting only viewable images, so make sure the files in the
wallpaper location are all suitable images. The default wallpaper location is
in ~/Pictures/Wallpapers and can be changed using the shufflepaper.conf

To have ShufflePaper select a background for you on a regular interval, use a
cron service like cronie and add a line like this to your crontab

\# Change background every ten minutes  
\*/10 * * * * fully/qualified/install/location/randomBG.sh

##Installation & Usage
Listed in more detail above
* Download project (anywhere you like)
* Set wallpaper location in shufflepaper.conf
* Run randomBG.sh (make sure it works)
* Set up cron or some manner of running the script recurringly
