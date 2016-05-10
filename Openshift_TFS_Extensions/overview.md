# Openshift Deploy Tools

![Almatoolbox Logo](http://logoshabm.tmdb.de/240/015095847.JPG "Almatoolbox Logo")

A collection of extensions for the RedHat Openshift Platform

# Contents
The extension consists in a set of tasks for managing images life cycle on Openshift platform: for each task, you'll need to specify connection parameters.

## Prerequisites
*Openshift Deploy Tools* requires the[Openshift Command Line Interface](https://docs.openshift.com/enterprise/3.0/cli_reference/get_started_cli.html#overview) on TFS host.

## Build starter
Performs a start-build on the target project using provided namespace
## Image Tagger
Tags an image
## Image promoter
Pulls then pushes an image on an external Docker for production.
It requires a Docker client machine (bridge)
- listening on port 22 (SSH)
- capable of connecting to your Docker Registry (which, of course, has to be exposed correctly by your Openshift environment)
Your TFS has to
- correctly connect via SSH to the Docker machine
- store the machine fingerprint (connect manually and say 'yes' to ssh prompt)

## Forthcoming
Support for RSA keys for Promotion Task

# License

*Openshift Deploy Tools*, as part of *AlmatoolBoxCE*, is distributed under GNU License.
