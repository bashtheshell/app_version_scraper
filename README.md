# App Version Scraper

The purpose of this repository is to **demonstrate** how one can retrieve the app version automatically from various sources that are publicly available to them. Rather than wasting time visiting the App/Play Store or downloading the binary files to the computer and execute the first phase of the installer to view the app version, we can either leverage the power of mobile app store's API and `curl` command-line tool to get the job done for us automatically.

This idea came to fruition after discovering that the software app distributor does not publicly list the version numbers on the webpage for unknown reason. Understandably, the verisons are already listed on the App Store and Play Store. When you install the apps, you'd be able to find the version number in the app. We can kindly put in a feedback request to have the app distributor provide the information on their webpage for our convenience. However, the request may not get fulfilled in a timely manner. 

In the meantime, we'd have to access this information on our own. Thankfully, the technology nowadays has made it feasible for us to retrieve this information automatically rather than checking each source manually. This would require some UNIX/Linux command-line scripting and web-development knowledge. The command-line utilities that made this possible are `bash`, `curl`, `sed`, `awk`, `grep`, `json_pp`, `unzip`, `exiftool`, and `crontab`. I've developed the complete [script](./apps_version.sh) to scrap the version periodically using cron job scheduler. In the next section, I'll go into detail.

## What Does the Scraping?

### For iOS:

Apple offers their users a way to fetch the information using their search API through the iTunes Store web service. Please see their [documentation](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#understand) for more information.

As shown in the snippet below (which is modified for demonstration), it's safe to say every app in iTunes store has an unique ID that one can look up. Clicking on the link (https://itunes.apple.com/lookup?id=423121946) would result in a downloadable JSON plain-text file containing all the details you'd see on the webpage [here](https://itunes.apple.com/us/app/convo-vrs/id423121946). 

```
curl -sf "https://itunes.apple.com/lookup?id=423121946" \
	| json_pp | awk -F':' '/"version"/ { print $2 }' \
	| sed 's/^\ "//' | sed 's/",//'
```

If you have access to `Terminal` program on macOS or other similar terminal program on Linux, you can safely copy and paste the above snippet and run it. You should see the version number in your output.

`curl` acts as a low-level web browser on the command-line. It's intended to be used as a developer tool to debug several Internet-based services. So it'd download the plain-text to your terminal screen for you. The `|` character is called a pipe, which would feed the output of the previous command (which is `curl` in our case) for the next command (`json_pp`) to use as an input to process. `json_pp` would beautify the JSON output in a human-readable format. Lastly, `awk` and `sed` are the most common command-line utilities used to search for patterns and truncate outputs.

### For Android:

Unfortunately, unlike Apple, Google Play Store does not offer an API for us to conveniently gather the information we want. I'd have to do some work by visiting the webpage directly through the browser [here](https://play.google.com/store/apps/details?id=com.convorelay.convomobile&hl=en_US) and inspect the web elements by viewing the source file. Luckily for us, it wasn't as difficult as one might think. Most webpage is actually an HTML script file. So, we'd get a plain-text file using `curl`. The file only contains few thousands lines, and we use `grep` to capture just the matching lines where the version number exists. 

```
curl -sf "https://play.google.com/store/apps/details?id=com.convorelay.convomobile&hl=en_US" \
	| grep -E 'Additional Information.*Current Version' | sed 's/^.*Current Version//' | sed 's/Requires Android.*$//' \
	| sed 's/^.*class="IQ1z0d"><span class="htlgb">//' | sed 's/<.*$//'
```

It's also safe to run the above snippet in your terminal program.

### For macOS:

Unlike the iOS app, the macOS app is not in the App Store. Otherwise, we'd be able to use the same approach as the iOS app. The only way to find out the version is to actually download the binary file directly from the software distributor. After unarchiving the downloaded zip file, we'd see that the file name contains the version number.

```
curl -sf -o Convo_macOS.zip "https://d3uqp1raf0m8tp.cloudfront.net/assets/downloads/Convo_macOS.zip"
if [ -f Convo_macOS.zip ]
then
	unzip -l Convo_macOS.zip | awk '/Convo-/ { print $4 }' | sed 's/Convo-//' \
		| sed 's/.sparkle_guided.pkg//'
	rm Convo_macOS.zip
fi
```

The above snippet would require `unzip` utility to be installed prior to running. Also, the script would take a few seconds to process since it'd temporarily download the file.

### For Windows:




###### <a name="disclaimer">1</a>: DISCLAIMER - This GitHub repository is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Convo Communications, LLC, or any of their subsidiaries or affiliates. All product and company names are the registered trademarks of their original owners. The use of any trade name or trademark is for demonstration, identification, and reference purposes only and does not imply any association with the trademark holder of their product brand.

