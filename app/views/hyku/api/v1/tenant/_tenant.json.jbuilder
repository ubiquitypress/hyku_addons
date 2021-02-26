# frozen_string_literal: true

json.id account.id
json.tenant account.tenant
json.cname account.cname
json.name account.name
json.solr_endpoint account.solr_endpoint_id
json.fcrepo_endpoint account.fcrepo_endpoint_id
json.redis_endpoint account.redis_endpoint_id
json.settings  @account.settings
# Avoid returning attributes beyond what the original UP API returned for now
json.partial! 'site', account: account, site: site
json.content_block content_blocks
