# Migration from UP Repos (Hyku 1) to HykuAddons (Hyku 2/3)
## Exporting from UP Repos
1. Go to Hyku 1 tenant dashboard
2. Click "Export Metadata"
3. Click "Export CSV for whole database"
4. Go to "Download CSV" tab and wait until download link appears
5. Download when available
## Preparing for import
### Create tenant
1. Run helm task for creating the new tenant
2. Setup admins (if necessary)
### Copying database
1. Dump and load postgres database
2. Anything else?
### Preparing files
1. Copy original files from AWS bucket to GCS bucket
### Preparing the import CSV
1. Run transformation script:
   ```
   bundle exec ruby bin/transform_export_batch.rb -i ~/Downloads/all_database.csv -o all_database.mod.csv
   ```
### Creating admin sets
1. Run admin set creation script:
   ```
   bundle exec rails r bin/create_admin_sets_for_import.rb <tenant_cname> all_database.mod.csv
   ```
## Running the import
1. Go to new tenant dashboard
2. Click Importers
3. Click New button
4. Fill out the form:
   1. Name: Migration
   2. Administrative Set: Default Admin Set
   3. Frequency: Once
   4. Limit: Leave blank
   5. Parser: Ubiquity Repositories Hyku 1 CSV
   6. Visibility: Public
   7. Rights Statement: Leave blank
   8. Upload a file: all_database.mod.csv
   9. Click Create and Import
## Post-import steps
### Collection metadata
### File visibility

