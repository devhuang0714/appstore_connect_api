# App Store Connect AP
Automate the tasks you perform on the Apple Developer website and in App Store Connect.

Usage: `appstore_connect_api.rb [options] [command [options]]`

```
Automate the tasks you perform on the Apple Developer website and in App Store Connect.

Usage: appstore_connect_api.rb [options] [command [options]]
    -h, --help                       Show all commands, or show usage for a command.

Generate Token commands:
        --generate-token             Create JSON Web Tokens signed with your private key to authorize API requests.

Beta Testers commands:
        --beta-testers-create        Create a beta tester assigned to a group, a build, or an app.
        --beta-testers-delete        Remove a beta tester's ability to test all apps.
        --beta-testers-list          Find and list beta testers for all apps, builds, and beta groups.
        --beta-testers-info          Get information about a specific bundle ID.

Beta Groups commands:
        --beta-groups-list           Find and list beta groups for all apps.

Bundle IDs commands:
        --bundle-ids-register        Register a new bundle ID for app development.
        --bundle-ids-modify          Update a specific bundle ID’s name.
        --bundle-ids-delete          Delete a bundle ID that is used for app development.
        --bundle-ids-list            Find and list bundle IDs that are registered to your team.
        --bundle-ids-info            Get information about a specific bundle ID.

Certificates commands:
        --certificates-create        Create a new certificate using a certificate signing request.
        --certificates-list          Find and list certificates and download their data.
        --certificates-info          Get information about a certificate and download the certificate data.
        --certificates-revoke        Revoke a lost, stolen, compromised, or expiring signing certificate.
        --certificates-download      Download the certificate data.

Devices commands:
        --devices-register           Register a new device for app development.
        --devices-modify             Update the name or status of a specific device.
        --devices-list               Find and list devices registered to your team.
        --devices-info               Get information for a specific device registered to your team.

Profiles commands:
        --profiles-create            Create a new provisioning profile.
        --profiles-delete            Delete a provisioning profile that is used for app development or distribution.
        --profiles-list              Find and list provisioning profiles and download their data.
        --profiles-info              Get information for a specific provisioning profile and download its data.
        --profiles-download          Download the provisioning profile data.

Users commands:
        --users-list                 Get a list of the users on your team.
        --users-info                 Get information about a user on your team, such as name, roles, and app visibility.
        --users-modify               Change a user's role, app visibility information, or other account details.
        --users-remove               Remove a user from your team.

User Invitations commands:
        --user-invitations-list      Get a list of pending invitations to join your team.
        --user-invitations-info      Get information about a pending invitation to join your team.
        --user-invitations-invite    Invite a user with assigned user roles to join your team.
        --user-invitations-cancel    Cancel a pending invitation for a user to join your team.
```

# Examples
## Generate Token
```
$ ruby appstore_connect_api.rb --generate-token --api-key-path path/to/your/api_key.json

eyJhbGciOiJFUzI1NiIsImtpZCI6aktMQ002SzMyVkEiLCJ0eDFASDFXAiOiJKV1QifQ.eyJpc3MiOiJjOTZmZjkyZi1mMTgzLTRmZjMtYmFmMS01ZmI1NDVlYTcyZDMiLCJleHAiOjE3MDU2NTMyMzUsImF1ZCI6ImFwcHN0b3JlY29ubmVjdC12MSJ9.HIK25mHBFAw3cqZ0gkxTXhuPeZKLmtg8-OLL0wl9UhYkZ8tsSJDl2L2vtMigAX-vliChkKD-IrXJqsn6WWNqQg
```

## Devices List
```
ruby appstore_connect_api.rb --devices-list --token eyJhbGciOiJFUzI1NiIsImtpZCI6aktMQ002SzMyVkEiLCJ0eDFASDFXAiOiJKV1QifQ.eyJpc3MiOiJjOTZmZjkyZi1mMTgzLTRmZjMtYmFmMS01ZmI1NDVlYTcyZDMiLCJleHAiOjE3MDU2NTMyMzUsImF1ZCI6ImFwcHN0b3JlY29ubmVjdC12MSJ9.HIK25mHBFAw3cqZ0gkxTXhuPeZKLmtg8-OLL0wl9UhYkZ8tsSJDl2L2vtMigAX-vliChkKD-IrXJqsn6WWNqQg

[EasyHTTP] Request Get: https://api.appstoreconnect.apple.com/v1/devices
[EasyHTTP] Headers: {"Authorization":"Bearer eyJhbGciOiJFUzI1NiIsImtpZCI6aktMQ002SzMyVkEiLCJ0eDFASDFXAiOiJKV1QifQ.eyJpc3MiOiJjOTZmZjkyZi1mMTgzLTRmZjMtYmFmMS01ZmI1NDVlYTcyZDMiLCJleHAiOjE3MDU2NTMyMzUsImF1ZCI6ImFwcHN0b3JlY29ubmVjdC12MSJ9.HIK25mHBFAw3cqZ0gkxTXhuPeZKLmtg8-OLL0wl9UhYkZ8tsSJDl2L2vtMigAX-vliChkKD-IrXJqsn6WWNqQg
","Content-Type":"application/json"}
[EasyHTTP] Query: {}
[EasyHTTP] Response code: 200
[EasyHTTP] Response body: {
  "data" : [ {
    "type" : "devices",
    "id" : "XXXXXXX01",
    "attributes" : {
      "addedDate" : "2024-01-03T10:22:31.000+00:00",
      "name" : "name_01",
      "deviceClass" : "IPAD",
      "model" : "iPad (9th generation)",
      "udid" : "00000-XXXXXXXXXXXXX-XXXXX",
      "platform" : "IOS",
      "status" : "ENABLED"
    },
    "links" : {
      "self" : "https://api.appstoreconnect.apple.com/v1/devices/XXXXXXXX01"
    }
  }, {
    "type" : "devices",
    "id" : "XXXXXXXXX02",
    "attributes" : {
      "addedDate" : "2024-01-03T10:21:58.000+00:00",
      "name" : "name_02",
      "deviceClass" : "IPHONE",
      "model" : "iPhone 14 Pro Max",
      "udid" : "00008120-00000000099998",
      "platform" : "IOS",
      "status" : "ENABLED"
    },
    "links" : {
      "self" : "https://api.appstoreconnect.apple.com/v1/devices/XXXXXXXXXX02"
    }
  } ],
  "links" : {
    "self" : "https://api.appstoreconnect.apple.com/v1/devices",
    "next" : "https://api.appstoreconnect.apple.com/v1/devices?cursor=eyJvZmZzZXQiOiIyMCJ9&limit=20"
  },
  "meta" : {
    "paging" : {
      "total" : 46,
      "limit" : 20
    }
  }
}
```
