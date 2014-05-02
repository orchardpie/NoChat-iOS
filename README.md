NoChat-iOS
==========

NoChat iOS client

Getting set up
==============
Be sure to specify your testflight credentials by setting environment variables:
`export TESTFLIGHT_API_TOKEN="youraccountapitoken"`
`export TESTFLIGHT_STAGING_TEAM_TOKEN="yourstagingteamtoken"`
`export TESTFLIGHT_PRODUCTION_TEAM_TOKEN="yourproductionteamtoken"`

Once these are set you can deploy your app through testflight with:

`rake testflight:deploy`

