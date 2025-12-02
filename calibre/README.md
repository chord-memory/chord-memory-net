# Calibre-Web

chord-memory.net utilizes [Calibre-Web](https://github.com/janeczku/calibre-web) to access progress % for eBooks on Kobo. The Kobo Sync feature of Calibre-Web allows progress % for eBooks to be automatically synced off of the Kobo over WiFi.

## Test Run Locally

To test run the official [calibre-web](https://hub.docker.com/r/linuxserver/calibre-web) image on Mac, cd into the `calibre` directory and run:
```
docker-compose up -d
```
and then view the Calibre-Web UI at http://localhost:8083. Ensure your Calibre desktop books are in `~/calibre-library`.

Login with creds:
* admin/admin123

On first launch:
* Calibre-Web will ask for the location of the Calibre library
* Enter /books (the path inside the container, not on your Mac)

## Deploy to AWS

// TODO
// Ensure to edit admin/admin123 PW upon deployment

## Kobo Sync Setup

Once your Calibre-Web instance is running in AWS via the Terraform deployment described above, we can configure Kobo Sync.

Next:
* In Calibre Web > Admin > Edit Basic Configuration > Feature Configuration, check "Enable Kobo Sync"
* Under the user profile "admin", click Create/View under Kobo Sync Token
* A popup with a value in the format `api_endpoint=https://example.com/kobo/xxxxxxxxxxxxxxxx` appears
* Connect the Kobo to a computer, and edit the `api_endpoint` config in `.kobo/Kobo/Kobo eReader.conf`
* Unmount the Kobo and click the circular arrows in the upper right corner and "Sync Now"

Books from Calibre-Web and will be synced when "Sync Now" is clicked and the progress % for these books synced to Calibre-Web upon opening/closing the books on the Kobo. 

Note that any sideloaded books synced from Calibre desktop will be duplicated. See below to safely transition from Calibre desktop to Calibre-Web.

## Transition from Desktop to Web

* Transfer annotations off of Kobo to Calibre desktop via Annotations plugin
* Write down current reading postition for in progress books or sync with KoboUtilities plugin
* Delete all sideloaded books from Kobo // TODO: one by one manually?
* Transfer books from Calibre-Web to Kobo by clicking "Sync Now" on Kobo
* Open in progress books and manually set them to correct reading position or sync with KoboUtilities plugin
* Annotations for previously sideloaded books now live in Calibre Desktop
// TODO: Ensure that Annotations for sideloaded books are not deleted when new Annotations get fetched

## Calibre Kobo Workflow

* Upload new ePubs to Calibre desktop
* // TODO: aws s3 sync followed by s3 to ebs sync so Calibre-Web has new data
* Click "Sync Now" on Kobo to send these books to Kobo
* Calibre-Web will convert them to kePub and store the kePub in Calibre desktop directory
* // TODO: now need to pull ebs from s3 back to local so kePubs are there?
* Can still use Calibre desktop to store Annotations
* Cannot use KoboUtilities edit book metadata & cover bc Calibre-Web loaded book will not be recognized by Calibre desktop on Kobo
* When [this PR](https://github.com/janeczku/calibre-web/pull/3381) is merged then book metadata & cover can be edited in Calibre desktop followed by aws s3/ebs sync and "Sync Now" on Kobo
