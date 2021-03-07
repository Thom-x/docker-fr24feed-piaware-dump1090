# Patching to add FlightRadar24 elements

This Docker image combines the PiAware and FR24feed programs to upload data simultaneously to both FlightAware (FA) and FlightRadar24 (FR24). \
The web UI comes from the [dump1090 version maintained by FA](https://github.com/flightaware/dump1090), and thus (logically ;) ) doesn't contain elements from their competitor FR24. We patch the web UI to provide:

* The logo and link to the FR24 website
* A neutral page title
* `[TODO]` Links to the flights pages for both FA and FR24
  * `[TODO]` Clicking on the flight number link
  * `[TODO]` When a flight is selected

This patch also provides some extra functionalities:
* `[TODO]` Two links to the public pages of one's own user/tracker on both platforms
* `[TODO]` A link to the local FR24Feed page, typically running at http://localhost:8754/

## Creating the patch for a new version

```
cd patch/
DUMP1090_VERSION=v3.8.1 ./refresh.sh
```

(update the value passed in `DUMP1090_VERSION` accordingly)

If the patch applied without issues, you're all set, nothing else to do than build the full Docker image.

If there were issues applying the patch file, it likely means that there were changes made upstream to the same lines that are changed by the patch, and you'll need to update the patch file. You can either:

* modify the patch file directly
* or edit the files in the `modified/dump1090-<version>` folder (likely `public_html/index.html`) to adapt for the changes that were made upstream to the lines that this patch applies to, and execute the following command to recreate the `.patch` file:
```
diff -ru upstream/ modified/ > flightradar24.patch
```
Note that if your text editor cleans up trailing whitespace, you might want to purge the newly created `patch/flightradar24.patch` file to remove unnecessary patched lines
  * `[TODO]`: ask/send a pull request to upstream to remove those unnecessary whitelines.


FR24 logo downloaded from https://www.flightradar24.com/static/images/svg/fr24-logo-no-payoff.svg
