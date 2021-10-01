# Deployment-Scripts
Scripts for deploying stuff like EMIE site-lists, etc...

GoLive-EMIE will extract version from the curret sitelist.xml and create a backup of the current version before copying and renaming the pilot /uat one. once that is done (and no issues have been reported) it will check for the existance of the prod file and will get it creation date and will display current time/date (these should be very close). you may need to edit webserver\EMIE$ path and also filenames to suit your setup/ org

Rollback-EMIE, will basically do the same as GoLive-EMIE, but in reverse, it will move current prod file out and postfix with .FAIL, It will then rollback previous version into place and check existance and creation date (again as it is copied, the creation date should be very close to exuction time)
