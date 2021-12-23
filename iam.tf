data "google_iam_policy" "no_auth_for_cloud_run_invoke" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy

resource "google_cloud_run_service_iam_policy" "no_auth_for_basic_express_microservice" {
  location    = google_cloud_run_service.basic_express_microservice.location
  project     = google_cloud_run_service.basic_express_microservice.project
  service     = google_cloud_run_service.basic_express_microservice.name
  policy_data = data.google_iam_policy.no_auth_for_cloud_run_invoke.policy_data
}

# ^ way to allow unauth'ed access to a microservice, i.e., if you don't have this configuration and try to hit the endpoint you'll get a 403
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-noauth

resource "google_service_account" "cloud_build_basic_express_sa" {
  account_id = "cloud-build-basic-express-sa"
}

resource "google_project_iam_custom_role" "cloud-build-basic-express-custom-role" {
  role_id     = "cloudBuildBasicExpress"
  title       = "Cloud Build Basic Express"
  description = "Custom role with permissions for cloud build to deploy basic express cloud run microservice"
  permissions = ["run.services.get", "cloudbuild.builds.create", "cloudbuild.builds.update", "cloudbuild.builds.list", "cloudbuild.builds.get", "logging.logEntries.create", "storage.buckets.create", "storage.buckets.get", "storage.buckets.list",
    "storage.objects.list",
    "storage.objects.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
  ]
  # adding permissions based on what I see in the console - under "IAM" there is the default cloud build service account (https://cloud.google.com/iam/docs/service-accounts#default), and under the little downward pointing arrow there is "analyzed permissions" - based on what I see here I am adding permissions, and aggregating with whatever else I need, e.g., for cloud run
  # also used this as guide - https://cloud.google.com/build/docs/cloud-build-service-account#default_permissions_of_service_account
  # shouldn't need storage access because in cloudbuild.yaml I set `CLOUD_LOGGING_ONLY` - https://cloud.google.com/build/docs/securing-builds/store-manage-build-logs#store-logs
}

resource "google_project_iam_binding" "cloud_build_basic_express_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloud-build-basic-express-custom-role.id
  members = [
    "serviceAccount:${google_service_account.cloud_build_basic_express_sa.email}",
    # when listing members it must follow this format
  ]
}

# ^ addresses - ERROR: (gcloud.run.deploy) PERMISSION_DENIED: Permission 'run.services.get' denied on resource 'namespaces/main-334018/services/basic-express-microservice' (or resource may not exist).
