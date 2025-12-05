# Calibre-Web

chord-memory.net utilizes [Calibre-Web](https://github.com/janeczku/calibre-web) to access progress % for eBooks on Kobo. The Kobo Sync feature of Calibre-Web allows progress % for eBooks to be automatically synced off of the Kobo over WiFi.

## Deploy Locally

Requires docker and docker-compose. For Mac, simply install Docker Desktop from the docker website [here](https://docs.docker.com/desktop/setup/install/mac-install/).

To test run the official [calibre-web](https://hub.docker.com/r/linuxserver/calibre-web) image on Mac, cd into the `calibre/local` directory and run:
```
docker-compose up -d
```
and then view the Calibre-Web UI at http://localhost:8083. Ensure your Calibre desktop books are in `~/calibre-library`, otherwise edit `~/calibre-library` in `calibre/local/docker-compose.yml` to the location of your Calibre desktop library on your Mac.

Login with creds:
* admin/admin123

On first launch:
* Calibre-Web will ask for the location of the Calibre library
* Enter /books (the path inside the container, not on your Mac)

Follow "Kobo Sync Setup" below to enable Kobo Sync between your local Calibre-Web instance and your Kobo. 

## Deploy to AWS

Requires the AWS CLI. Install using [Homebrew](https://brew.sh/).
```
brew update
brew install awscli
aws --version
```

Manual AWS Console Steps:
* Buy Route53 domain
* Take note of the Hosted Zone ID
* Enable the IAM Identity Center

Within IAM Identity Center:
* Create a Permission set "AdministratorAccess" with the "AdministratorAccess" AWS Managed Policy
* Create a Group "Administrators"
* Navigate to "AWS Accounts"
* Select the account where you will be deploying resources
* Click "Assign users or groups"
* Select the "Administrators" group and "AdministratorAccess" permission set to link them
* Create a user for yourself in the "Administrators" group
* Create your password by clicking "Accept Invitation" in the received email
* Sign in to setup MFA device

Login to AWS in the CLI:
* Execute `aws configure sso`:
```
jordan@Jordans-MBP calibre-web-aws % aws configure sso
SSO session name (Recommended): jordan-sso
SSO start URL [None]: https://d-XXXXXXXXXX.awsapps.com/start
SSO region [None]: us-east-1
SSO registration scopes [sso:account:access]:
Attempting to open your default browser.
If the browser does not open, open the following URL:

https://oidc.us-east-1.amazonaws.com/authorize?response_type=code&client_id=vurAE0VZDjczgMoDyWp2knVzLWVhc3QtMQ&redirect_uri=http%3A%2F%2F127.0.0.1%3A50327%2Foauth%2Fcallback&state=dcd74d4b-99a0-4965-b90a-5702e1e1d53e&code_challenge_method=S256&scopes=sso%3Aaccount%3Aaccess&code_challenge=mZjrl_HVMO8N9H_HRRZTv4B2nEMBxJI22bz6DciVyJ8
The only AWS account available to you is: 123456789012
Using the account ID 123456789012
The only role available to you is: AdministratorAccess
Using the role name "AdministratorAccess"
Default client Region [None]: us-east-1
CLI default output format (json if not specified) [None]:
Profile name [AdministratorAccess-123456789012]: jordan-sso
To use this profile, specify the profile name using --profile, as shown:

aws sts get-caller-identity --profile jordan-sso
jordan@Jordans-MBP calibre-web-aws %
```
* Enter a session name like `jordan-sso`
* This helps to organize the `~/.aws/config` file
* Enter the portal URL from the email or from the IAM Identity Center settings
* Enter the region where your account is located
* Press enter when prompted for SSO registration scopes
* Enter the region where your account is located again
* Press enter when prompted for CLI default output format
* Enter a profile name like `jordan-sso`
* Your `~/.aws/config` file should look like:
```
jordan@Jordans-MBP calibre-web-aws % cat ~/.aws/config
[profile jordan-sso]
sso_session = jordan-sso
sso_account_id = 123456789012
sso_role_name = AdministratorAccess
region = us-east-1
[sso-session jordan-sso]
sso_start_url = https://d-XXXXXXXXXX.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```
* And you can see your profile here:
```
jordan@Jordans-MBP calibre-web-aws % aws configure list-profiles
jordan-sso
```
* Run `aws sts get-caller-identity --profile jordan-sso` to see your UserID, Account, and Arn
* This confirms that you are authenticated
* To run aws commands without the `--profile` argument: `export AWS_PROFILE=jordan-sso`
* Now you can see the same UserID, Account, and Arn output from `aws sts get-caller-identity`
* When your session expires, you can restart it with `aws sso login --profile jordan-sso`

Generate a `terraform.tfvars` file in `calibre/terraform` with the following variables:
```
domain_name = "cweb.my-domain.net"
hosted_zone_id = "ZXXXXXXXXXXXXX"
admin_pass = "CHANGEME"
adnim_email = "you@example.com"
region = "us-east-1"
```

```
terraform init
terraform apply
```

## Kobo Sync Setup

Once your Calibre-Web instance is running in AWS via the Terraform deployment described above, we can configure Kobo Sync.

Note:
* You can test sync your Kobo with your local Calibre-Web instance
* The same steps below may be followed however you must visit your Calibre-Web instance at your Macs public IP
* Run `ipconfig getifaddr en0` or `ipconfig getifaddr en1` to get your Macs public IP
* Navigate to your local Calibre-Web instance in the browser at `http://<Macs public IP>:8083`
* And then continue with the steps below

Note:
* The sync will only work with your local Calibre-Web if your Mac & Kobo are on the same WiFi network
* And the AP Isolation setting on the WiFi router is disabled
* The AP Isolation setting disallows devices on the same network from communicating
* Try visiting `http://<Macs public IP>:8083` from your phone on the same WiFI network to troubleshoot this
* If your Calibre-Web UI appears in the browser on your phone then the Kobo sync should work

Next:
* In Calibre Web > Admin > Edit Basic Configuration > Feature Configuration, check "Enable Kobo Sync"
* Under the user profile "admin", click Create/View under Kobo Sync Token
* A popup with a value in the format `api_endpoint=https://example.com/kobo/xxxxxxxxxxxxxxxx` appears
* Connect the Kobo to a computer, and edit the `api_endpoint` config in `.kobo/Kobo/Kobo eReader.conf`
* Unmount the Kobo and click the circular arrows in the upper right corner and "Sync Now"

Books from Calibre-Web and will be synced when "Sync Now" is clicked and the progress % for these books synced to Calibre-Web upon opening/closing the books on the Kobo.

If running Calibre-Web locally you can use `sqlite3 calibre/local/config/app.db` to view the progress % changing for books synced by Calibre-Web:
```
jordan@Jordans-MBP calibre-web-aws % sqlite3 calibre/local/config/app.db
SQLite version 3.43.2 2023-10-10 13:08:14
Enter ".help" for usage hints.
sqlite> .table
archived_book       flask_dance_oauth   kobo_synced_books   shelf             
book_read_link      flask_settings      oauthProvider       shelf_archive     
book_shelf_link     kobo_bookmark       registration        thumbnail         
bookmark            kobo_reading_state  remote_auth_token   user              
downloads           kobo_statistics     settings            user_session      
sqlite> pragma table_info(kobo_bookmark);
0|id|INTEGER|1||1
1|kobo_reading_state_id|INTEGER|0||0
2|last_modified|DATETIME|0||0
3|location_source|VARCHAR|0||0
4|location_type|VARCHAR|0||0
5|location_value|VARCHAR|0||0
6|progress_percent|FLOAT|0||0
7|content_source_progress_percent|FLOAT|0||0
sqlite> select progress_percent from kobo_bookmark where progress_percent is not null;
9.0
7.0
8.0
11.0
sqlite>
```

If running Calibre-Web on AWS you can SSH into the EC2 to look at the database or use the provided API endpoints:
// TODO

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


## Manually Sync Calibre Desktop & Calibre-Web

When edits are made to Calibre Desktop such as new ePubs added or Annotations synced to it, these changes may be synced to Calibre-Web by running the following commands:
```
# Configure profile
aws configure --profile calibre-sync
# On Mac
aws s3 sync ./my-local-library s3://my-bucket
# SSH into EC2
aws ssm start-session --target i-xxxxxxxx
# On EC2
aws s3 sync s3://my-bucket /mnt/ebs-library
```
