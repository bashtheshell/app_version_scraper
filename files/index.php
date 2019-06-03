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