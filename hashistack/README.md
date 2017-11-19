## GCP Instructions

First you need a project.  Then you need to create a service account so you can access and download a JSON file that contains authentication information.  You will need this file to interact with GCP.

If you have created a new project for this you will also need to enable the necessary APIs.  You can do this from the GCP web console, or by issuing the following commands (assuming you have installed the gcloud command line tool).

```
gcloud auth login
gcloud config set project $YOUR_PROJECT_NAME
gcloud service-management enable compute.googleapis.com
```

When testing locally you will need to set the proper environment variables.  Make a copy of the env.sh.example file with the proper values, and source it.

```
cp env.sh.example env.sh
vim env.sh
source env.sh
```

### Things To Be Aware Of
 - GCP does not like capital letters or characters other than dash (-).  Text fields must be all lowercase, and cannot contain periods/dots or any other punctuation.
 - To build opensource hashistack leave the $PRODUCT_ENT_URL vars blank.

### Additional Reading
https://cloud.google.com/solutions/image-management-best-practices
https://cloud.google.com/compute/docs/images/sharing-images-across-projects
