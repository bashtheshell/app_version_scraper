# App Version Scraper

The purpose of this repository is to **demonstrate** how one can retrieve the app version automatically from various sources that are publicly available to them. Rather than wasting time visiting the *App Store* or *Play Store* or downloading the binary files to the computer and execute the first phase of the installer to view the app version, we can either leverage the power of mobile app store's API and `curl` command-line tool to get the job done for us automatically.

This idea came to fruition after discovering that the software app distributor does not publicly list the version numbers on the webpage for unknown reason. Understandably, the verison are already listed on the *App Store* and *Play Store*, and when you install the apps, you'd be able to find the version number in the app. We can kindly put in a feedback request to have the app distributor provide the information on their webpage for our convenience. However, the request may not get fulfilled in a timely manner. 

In the meantime, we'd have to access this information on our own. Thankfully, the technology nowadays has made it feasible for us to retrieve this information automatically rather than checking each source manually. This would require some UNIX/Linux command-line scripting and web-development knowledge. The command-line utilities that made this possible are `bash`, `curl`, `sed`, `awk`, `grep`, `json_pp`, `unzip`, and `exiftool`. I've developed the [script](./) to scrap the version periodically. 




###### <a name="disclaimer">1</a>: DISCLAIMER - This GitHub repository is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Convo Communications, LLC, or any of their subsidiaries or affiliates. All product and company names are the registered trademarks of their original owners. The use of any trade name or trademark is for demonstration, identification, and reference purposes only and does not imply any association with the trademark holder of their product brand.

