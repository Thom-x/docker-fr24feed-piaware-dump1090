# Fr24feed and FlightAware with dump1090 as a Docker image

![Build status](https://github.com/Thom-x/docker-fr24feed-piaware-dump1090/workflows/Docker/badge.svg?branch=master)
![GitHub issues](https://img.shields.io/github/issues/Thom-x/docker-fr24feed-piaware-dump1090)

![Latest image version](https://img.shields.io/docker/v/thomx/fr24feed-piaware?sort=semver)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/thomx/fr24feed-piaware)

![License](https://img.shields.io/github/license/Thom-x/docker-fr24feed-piaware-dump1090)

> Please consider following this project's author, [Thom-x](https://github.com/Thom-x), and consider starring the project to show your ❤️ and support.

Docker image of Fr24feed, FlightAware and dump1090.

Feed FlightRadar24 and FlightAware, allow you to see the positions of aircrafts on a map.

---

![Image of dump1090 webapp](https://raw.githubusercontent.com/Thom-x/docker-fr24feed-piaware-dump1090/master/screenshot.png)

# Requirements
- Docker
- RTL-SDR DVBT USB Dongle (RTL2832)

# Getting started

Run : 
```
docker run -d -p 8080:8080 -p 8754:8754 \
	--device=/dev/bus/usb:/dev/bus/usb \
	-v "/etc/localtime:/etc/localtime:ro" \
	-e "FR24FEED_FR24KEY=MY_SHARING_KEY" \
	-e "PIAWARE_FEEDER_DASH_ID=MY_FEEDER_ID" \
	-e "HTML_SITE_LAT=MY_SITE_LAT" \
	-e "HTML_SITE_LON=MY_SITE_LON" \
	-e "HTML_SITE_NAME=MY_SITE_NAME" \
	-e "PANORAMA_ID=MY_PANORAMA_ID" \
	-e "LAYERS_OWM_API_KEY=MY_OWM_API_KEY" \
	-e "SERVICE_ENABLE_ADSBEXCHANGE=true" \
	-e "ADSBEXCHANGE_UUID=MY_UUID" \
	-e "ADSBEXCHANGE_STATION_NAME=MY_STATION_NAME" \
	-e "MLAT_EXACT_LAT=MY_EXACT_SITE_LAT" \
	-e "MLAT_EXACT_LON=MY_EXACT_SITE_LON" \
	-e "MLAT_ALTITUDE_MSL_METERS=MY_SITE_ALT_MSL_METERS" \
	thomx/fr24feed-piaware
```

Go to http://dockerhost:8080 to view a map of reveived data.
Go to http://dockerhost:8754 to view the FR24 Feeder configuration panel.

*Note : remove `-e "PANORAMA_ID=MY_PANORAMA_ID"` or `-e "LAYERS_OWM_API_KEY=MY_OWM_API_KEY"` from the command line if you don't want to use this feature.*
*Note : `-v "/etc/localtime:/etc/localtime:ro"` is needed for MLAT, or you can have issues with time synchronization.*

# Configuration

## Common

To disable starting a service you can add an environement variable :

| Environment Variable                  | Value                    | Description               |
|---------------------------------------|--------------------------|---------------------------|
| `SERVICE_ENABLE_DUMP1090`             | `false`                  | Disable dump1090 service  |
| `SERVICE_ENABLE_PIAWARE`              | `false`                  | Disable piaware service   |
| `SERVICE_ENABLE_FR24FEED`             | `false`                  | Disable fr24feed service  |
| `SERVICE_ENABLE_HTTP`                 | `false`                  | Disable http service      |
| `SERVICE_ENABLE_IMPORT_OVER_NETCAT`   | `false`                  | Disable import over netcat|
| `SERVICE_ENABLE_ADSBEXCHANGE`         | `false`                  | Disable adsbexchange feed |


Ex : `-e "SERVICE_ENABLE_HTTP=false"`


## FlightAware

Resgister on https://flightaware.com/account/join/.

Run :
```
docker run -it --rm \
	-e "SERVICE_ENABLE_DUMP1090=false" \
	-e "SERVICE_ENABLE_HTTP=false" \
	-e "SERVICE_ENABLE_FR24FEED=false" \
	-e "SERVICE_ENABLE_ADSBEXCHANGE=false" \
	thomx/fr24feed-piaware /bin/bash
```
When the container starts you should see the feeder id, note it. Wait 5 minutes and you should see a new receiver at https://fr.flightaware.com/adsb/piaware/claim (use the same IP as your docker host), claim it and exit the container.

Add the environment variable `PIAWARE_FEEDER_DASH_ID` with your feeder id.

| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `PIAWARE_FEEDER_DASH_ID`              | `feeder-id`              | `YOUR_FEEDER_ID`  |
| `PIAWARE_RECEIVER_DASH_TYPE`          | `receiver-type`          | `other`           |
| `PIAWARE_RECEIVER_DASH_HOST`          | `receiver-host`          | `127.0.0.1`       |
| `PIAWARE_RECEIVER_DASH_PORT`          | `receiver-port`          | `30005`           |


Ex : `-e "PIAWARE_RECEIVER_DASH_TYPE=other"`

## FlightRadar24

Run :
```
docker run -it --rm \
	-e "SERVICE_ENABLE_DUMP1090=false" \
	-e "SERVICE_ENABLE_HTTP=false" \
	-e "SERVICE_ENABLE_PIAWARE=false" \
	-e "SERVICE_ENABLE_FR24FEED=false" \
	-e "SERVICE_ENABLE_ADSBEXCHANGE=false" \
	thomx/fr24feed-piaware /bin/bash
```

Then : `/fr24feed/fr24feed/fr24feed --signup` and follow the instructions, for technical steps, your answer doesn't matter we just need the sharing key at the end.

Finally to see the sharing key run `cat /etc/fr24feed.ini`, you can now exit the container.

Add the environment variable `FR24FEED_FR24KEY` with your sharing key.


| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `FR24FEED_RECEIVER`                   | `receiver`               | `beast-tcp`       |
| `FR24FEED_FR24KEY`                    | `fr24key`                | `YOUR_KEY_HERE`   |
| `FR24FEED_HOST`                       | `host`                   | `127.0.0.1:30005` |
| `FR24FEED_BS`                         | `bs`                     | `no`              |
| `FR24FEED_RAW`                        | `raw`                    | `no`              |
| `FR24FEED_LOGMODE`                    | `logmode`                | `1`               |
| `FR24FEED_LOGPATH`                    | `logpath`                | `/tmp`            |
| `FR24FEED_MLAT`                       | `mlat`                   | `yes`             |
| `FR24FEED_MLAT_DASH_WITHOUT_DASH_GPS` | `mlat-without-gps`       | `yes`             |

Ex : `-e "FR24FEED_FR24KEY=0123456789"`

## ADS-B Exchange


Add the environment variable `ADSBEXCHANGE_UUID` with a UUID generated by <https://www.adsbexchange.com/myip/gen-uuid/>.
In case of multiple receivers, please use a different UUID for each receiver.

Add the environment variable `SERVICE_ENABLE_ADSBEXCHANGE` and set it to `true`.


| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `SERVICE_ENABLE_ADSBEXCHANGE`         | `enable this feed client`| `false`           |
| `ADSBEXCHANGE_UUID`                   | `uuid (required)`        | `none`            |
| `ADSBEXCHANGE_STATION_NAME`           | `station name`           | `none`            |
| `ADSBEXCHANGE_MLAT`                   | `mlat`                   | `true`            |

Configure the MLAT coordinates so that adsbexchange MLAT can work. (see its own section below)
If you don't want to supply your exact coordinates, please set the `ADSBEXCHANGE_MLAT` environment variable to `false`. (you won't get MLAT results and won't contribute to MLAT)

Add the environment variable `ADSBEXCHANGE_STATION_NAME`, it will be used for the mlat map / sync status.
You can check that your MLAT is working correctly by searching for your station name here: <https://map.adsbexchange.com/mlat-map/>
(MLAT map marker is snapped to a 5 mile grid and then offset randomly to avoid stacking markers, the precise lat / lon for MLAT are not publicly accessible at adsbexchange)

The ADS-B Exchange Anywhere map will be available at: <https://www.adsbexchange.com/api/feeders/?feed=MY_UUID>

## Exact coordinates for MLAT

Get your exact coordinates and altitude above sealevel in meters from one these websites:
 - <https://www.freemaptools.com/elevation-finder.htm>
 - <https://www.mapcoordinates.net/en>

It's important for MLAT accuracy that these aren't off by more than about 10 m / 30 ft.

| Environment Variable                  | Configuration property   | Default value     |
|---------------------------------------|--------------------------|-------------------|
| `MLAT_EXACT_LAT`                      | `decimal latitude`       | `none`            |
| `MLAT_EXACT_LON`                      | `decimal longitude`      | `none`            |
| `MLAT_ALTITUDE_MSL_METERS`            | `altitude above MSL in m`| `none`            |

## Add custom properties

**Note** : you can add any property to either fr24feed or piaware configuration file by adding an environment variable starting with `PIAWARE_...` or `FR24FEED_...`.

Example :

| Environment Variable                  | Configuration property   | value             | Configuration file      |
|---------------------------------------|--------------------------|-------------------|-------------------------|
| `FR24FEED_TEST=value`                 | `test`                   | `value`           | `fr24feed.init`         |
| `FR24FEED_TEST_DASH_TEST=value2`      | `test-test`              | `value2`          | `fr24feed.init`         |
| `PIAWARE_TEST=value`                  | `test`                   | `value`           | `piaware.conf`          |

## Dump1090 & Web UI

| Environment Variable                  | Default value            | Description                                                       |
|---------------------------------------|--------------------------|-------------------------------------------------------------------|
| `HTML_SITE_LAT`                       | `45.0`                   |                                                                   |
| `HTML_SITE_LON`                       | `9.0`                    |                                                                   |
| `HTML_SITE_NAME`                      | `My Radar Site`          |                                                                   |
| `HTML_DEFAULT_TRACKER`                | `FlightAware`            | Which flight tracker website to use by default. Possible values are `FlightAware` and `Flightradar24`|
| `HTML_RECEIVER_STATS_PAGE_FLIGHTAWARE`  | empty            | URL of your receiver's stats page on FlightAware. Usually https://flightaware.com/adsb/stats/user/ |
| `HTML_RECEIVER_STATS_PAGE_FLIGHTRADAR24`  | empty            | URL of your receiver's stats page on Flightradar24. Usually https://www.flightradar24.com/account/feed-stats/?id=<ID> |
| `HTML_FR24_FEEDER_STATUS_PAGE`  | empty            | URL of your local FR24 Feeder Status page. Usually http://<dockerhost>:8754/ (depends on the port you indicated when starting the container) |
| `DUMP1090_ADDITIONAL_ARGS`            | empty                    | Additial arguments for dump1090 e.g.: `--json-location-accuracy 2`|

Ex : `-e "HTML_SITE_NAME=My site"`

## DUMP1090 forwarding
| Environment Variable                  | Default value            | Description                                                       |
|---------------------------------------|--------------------------|-------------------------------------------------------------------|
| `SERVICE_ENABLE_IMPORT_OVER_NETCAT`   | `false`                  | Enable netcat forwarding the beast-output of a remote dump1090 server to the local dump1090 beast-input |
| `DUMP1090_LOCAL_PORT`                 | empty                    | Must be the same port as specified as `--net-bi-port` in  `DUMP1090_ADDITIONAL_ARGS`|
| `DUMP1090_REMOTE_HOST`                | empty                    | IP of remote dump1090 server                                      |
| `DUMP1090_REMOTE_PORT`                | empty                    | Port of remote dump190 server specified as argument `--net-bo-port` on remote system|

## RTL_TCP forwarding

**WARNING:** This kind of forwarding is using a lot of bandwidth and could be unstable in WiFi environments.

| Environment Variable                  | Default value            | Description                                                       |
|---------------------------------------|--------------------------|-------------------------------------------------------------------|
| `RTL_TCP_OVER_NETCAT`                | `false`                  | Use dump1090 in combination with netcat to feed data from rtl_tcp server. (Requires appox. 35-40Mbit/s). Example RTL_TCP command: `./rtl_tcp -a 0.0.0.0 -f 1090000000 -s 2400000 -p 30005 -P 28 -g -10`|
| `RTL_TCP_REMOTE_HOST`                | empty                    | IP of rtl_tcp server                                              |
| `RTL_TCP_REMOTE_PORT`                | empty                    | Port of rtl_tcp server                                            |

## Terrain-limit rings (optional):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

| Environment Variable                  | Default value            | Description                                 |
|---------------------------------------|--------------------------|---------------------------------------------|
| `PANORAMA_ID`                         |                          | Panorama id                                 |
| `PANORAMA_ALTS`                       | `1000,10000`             | Comma seperated list of altitudes in meter  |

*Note : the panorama id value correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*

Ex : `-e "PANORAMA_ID=FRUXK2G7"`

If you don't want to download the limit every time you bring up the container you can download `http://www.heywhatsthat.com/api/upintheair.json?id=${PANORAMA_ID}&refraction=0.25&alts=${PANORAMA_ALTS}` as upintheair.json and mount it in `/usr/lib/fr24/public_html/upintheair.json`.

## Open Weather Map layers:
If you don't need this feature ignore this.

If you provide an API key OWM layers will be available.
Create an account and get an API key on https://home.openweathermap.org/users/sign_up.
Be aware that OWM provides a free trier for its API, after some time you will have to pay.
See: https://openweathermap.org/price

| Environment Variable                  | Default value            | Description                                 |
|---------------------------------------|--------------------------|---------------------------------------------|
| `LAYERS_OWM_API_KEY`                  |                          | Open Weather Map API Key                    |

Ex : `-e "LAYERS_OWM_API_KEY=dsf1ds65f4d2f65g"`

# Build it yourself

Clone this repo.

```docker build . ```
