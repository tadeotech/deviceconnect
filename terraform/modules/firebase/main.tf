/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

# Enabling a firbase project
resource "google_firebase_project" "default-firebase" {
  project = var.project_id
}

# Creating the firestore instance
resource "google_firestore_database" "default-firestore" {
  project       = var.project_id
  type          = "FIRESTORE_NATIVE"
  name          = "(default)"
  location_id   = var.firestore_region
}


resource "google_storage_bucket" "firestore-backup-bucket" {
  name          = "${var.project_id}-firestore-backup"
  location      = var.storage_multiregion
  storage_class = "NEARLINE"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 356
    }
    action {
      type = "Delete"
    }
  }
}

# module "firebase_backup_sa" {
#   source       = "terraform-google-modules/service-accounts/google"
#   version      = "~> 3.0"
#   project_id   = var.project_id
#   names        = ["firebase-backup"]
#   display_name = "Firebase backup service account"
#   description  = "Service account for Firestore"
#   project_roles = [for i in [
#     "roles/datastore.owner",
#     "roles/firebase.admin",
#     "roles/logging.admin",
#     "roles/secretmanager.secretAccessor",
#     "roles/storage.admin",
#   ] : "${var.project_id}=>${i}"]
#   generate_keys = false
# }

# # give backup SA rights on bucket
# resource "google_storage_bucket_iam_binding" "firestore_sa_backup_binding" {
#   bucket = google_storage_bucket.firestore-backup-bucket.name
#   role   = "roles/storage.admin"
#   members = [
#     "serviceAccount:firebase-backup@${var.project_id}.iam.gserviceaccount.com",
#   ]
#   depends_on = [
#     module.firebase_backup_sa,
#     google_storage_bucket.firestore-backup-bucket
#   ]
# }
