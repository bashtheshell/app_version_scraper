# App Version Scraper

The purpose of this repository is to **demonstrate** how one can retrieve the app version automatically from various sources that are publicly available to them. Rather than wasting time visiting the App/Play Store or downloading the binary files to the computer and execute the first phase of the installer to view the app version, we can either leverage the power of mobile app store's API and `curl` command-line tool to get the job done for us automatically.

## Motivation

This idea came to fruition after discovering that the software app distributor does not publicly list the version numbers on the webpage for unknown reason. Understandably, the verisons are already listed on the App Store and Play Store. When you install the apps, you'd be able to find the version number in the app. We can kindly put in a feedback request to have the app distributor provide the information on their webpage for our convenience. However, the request may not get fulfilled in a timely manner. 

In the meantime, we'd have to access this information on our own. Thankfully, the technology nowadays has made it feasible for us to retrieve this information automatically rather than checking each source manually. This would require some UNIX/Linux command-line scripting and web-development knowledge. The command-line utilities that made this possible are `bash`, `curl`, `sed`, `awk`, `grep`, `json_pp`, `unzip`, `exiftool`, and `crontab`. I've developed the complete [script] to scrap the version periodically using cron job scheduler. In the next section, I'll go into detail.

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

The approach for Windows is almost similar to the macOS. However, the downloaded `.exe` file doesn't contain the version number. The `exiftool`, which can be found [here](https://www.sno.phy.queensu.ca/~phil/exiftool/), has the ability to read the file's tags or metadata. The `.exe` file contains several useful tags, including the name of the developer. Although, we only need the version infomation. 

```
curl -sf -o Convo_Windows.exe "https://d3uqp1raf0m8tp.cloudfront.net/assets/downloads/Convo_Windows.exe"
if [ -f Convo_Windows.exe ]
then
	exiftool -a Convo_Windows.exe | awk -F':' '/File Version [^Number]/ { print $2 }' \
		| sed 's/^\ //' 
	rm Convo_Windows.exe
fi
```

## Presentation

We'd need a way to centrally present the information, and we can do so by hosting it on a web server. With my limited web-development knowledge, I decided to use PHP, which I have no in-depth experience with, to automatically render a HTML page with the desired information. PHP was a sensible choice as it's very intuitive for anyone who's familiar with HTML and a scripting language such as Bash or Perl. Here is the HTML file below containing the PHP script.

```
<!DOCTYPE html>
<html>
    <head>
        <title>Convo Apps Version Viewer</title>
    </head>
    <body>
        <h2>Convo Apps</h2>
        <?php
        $convo_versions = array();
        $convo_platforms = ["android", "ios", "macos", "windows"];
        $convo_version_files = array("convo_android.txt", "convo_ios.txt", "convo_macos.txt", "convo_windows.txt");
        $i = 0;

        foreach ($convo_version_files as $file) {
            $tmp_file = fopen($file, "r") or die("Error: Unable to open the file.");
            $convo_versions += [$convo_platforms[$i] => fgets($tmp_file)];
            fclose($tmp_file);
            $i++;
        }
        ?>
        <table style="width:20%">
            <tr>
                <th>Platform</th>
                <th>Version</th> 
            </tr>
            <tr>
                <td>macOS</td> 
                <td><?php echo $convo_versions['macos'];?></td> 
            </tr>
            <tr>
                <td>iOS</td>
                <td><?php echo $convo_versions['ios'];?></td> 
            </tr>
            <tr>
                <td>Windows</td>
                <td><?php echo $convo_versions['windows'];?></td> 
            </tr>
            <tr>
                <td>Android</td> 
                <td><?php echo $convo_versions['android'];?></td> 
            </tr>
        </table>
    </body>
</html>
```

The above `index.php` script is located in the web server's document root directory along with the version files created by the [scraper script](./files/apps_version.sh) in a separate location. I used `crontab` to have the scraper script runs every o'clock and create or update the four plain-text files containing the version number for the PHP script to read from.

## See It in Action

I have created a playbook to quickly deploy the configuration I made for the users to see how the scraping works. This would require one to be familar with Ansible, SSH service, and access to a virtual machine or cloud service provider. I used Digital Ocean cloud service provider as they offer a low-cost, effective VM solution. Ansible 2.8 was used at the time of this writing.

In order to run the [playbook](./ubuntu18-04_server_playbook.yml), you should have the following requirements:

- A controller machine with macOS or Linux installed (e.g. a desktop or laptop you'd use to remote in a VM via SSH)
- The controller machine must have Python 3.7+ installed. It's recommended to install Python from [Python.org](https://www.python.org/downloads/)
- On the remote machine (typically a local VM or a VM on cloud provider), the operating system must be Ubuntu 18.04 LTS+
- Must have access to *root* user account with SSH public key installed in `/root/.ssh/authorized_keys` directory on the remote machine with a private key pair on the local machine, of course. This configuration is typically the default with Digital Ocean droplets. *While this is not a recommended security practice, this is intentionally done for the sake of quick demonstration. It's recommended to use a non-root user account with passwordless `sudo` privilege with Ansible.*

In the terminal on your controller machine, run the following:

```
# download the repository and set up the virtual environment to run the playbook
git clone git@github.com:bashtheshell/app_version_scraper.git
cd app_version_scraper
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install ansible

# not required but to quickly test ansible setup using ad-hoc command and make sure you're properly connected
# -u is for the remote user, --private-key is for the private SSH key used to connect remotely
# Don't forget the comma after the IP address. Uncomment the next line to test
# ansible all -i "remote.server.ip.address," -m ping -u root --private-key=~/.ssh/remoteserver-id_rsa

# to run the playbook
ansible-playbook -i "remote.server.ip.address," ubuntu18-04_server_playbook.yml --private-key=~/.ssh/remoteserver-id_rsa
```

After the playbook completed its run, you should be able to view the webpage through the web browser. Please go to `http://remote.server.ip.address/`

When you are done, you can shutdown and delete the VM as well as deleting the current project folder.

```
# clean up current directory
deactivate
cd ..
rm -rf ./app_version_scraper
```

## Known Issues

- If a text file containing the version does not exist, then the PHP script would exit immediately, leaving the HTML rendering incomplete. Yes, you can expect a broken page. This is expected due to the following line containing the `die()` [function](https://www.php.net/manual/en/function.die.php) in the PHP script: `$tmp_file = fopen($file, "r") or die("Error: Unable to open the file.");`. Because of my limited expertise and the sole purpose of this repository, I do not plan on improving the error-handling in the future.

</br>

---

### DISCLAIMER

<a name="disclaimer">1</a>: This GitHub repository is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Convo Communications, LLC, or any of their subsidiaries or affiliates. All product and company names are the registered trademarks of their original owners. The use of any trade name or trademark is for demonstration, identification, and reference purposes only and does not imply any association with the trademark holder of their product brand.

