### Build new drupal8 base image

`cd drupal8_image_builder`

(creates the image on your computer)

`docker build -t {path to your registry}/drupal8:{some tag} .`

(pushes the image to the repo)

`docker push {path to your registry}/drupal8:{tag}`

### If you need to pull a folder out of a container to your host OS.  For example, if the drupal project changed to a different themes structure and you need to copy that folder from the container to your host OS.

`docker cp webapp:/drupal_app/web/themes/ ./drupal8_theme`

