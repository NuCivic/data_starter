; Drush make file for the data_starter package, a site template based on the
; DKAN distribution of Drupal with additional NuCivic, Acquia and contrib modules

; Grab DKAN make file
includes[dkan] = build-dkan.make

; Set the default subdirectory for projects so we don't have to specifically set it each time, but make sure dkan stays in /profiles
defaults[projects][subdir] = contrib
projects[dkan][subdir] = ""

; Development
; ===========
projects[] = devel
projects[] = environment
projects[] = maillog
projects[] = shield
projects[] = features_override
projects[] = security_review

; Acquia
; ======
projects[] = acquia_connector
; Acquia Expire integration
projects[] = acquia_purge
; Acquia Search modules
projects[] = search_api_acquia
projects[] = acquia_search_multi_subs

; Search
; ======
projects[] = search_api_solr

; DKAN
; =====
projects[data_disqus][download][type] = git
projects[data_disqus][download][url] = git@github.com:NuCivic/data_disqus.git
projects[data_disqus][download][branch] = master

projects[data_workflow][download][type] = git
projects[data_workflow][download][url] = git@github.com:NuCivic/data_workflow.git
projects[data_workflow][download][branch] = master

projects[visualization_entity][download][type] = git
projects[visualization_entity][download][url] = git@github.com:NuCivic/visualization_entity.git
projects[visualization_entity][download][branch] = master

projects[visualization_entity_charts][download][type] = git
projects[visualization_entity_charts][download][url] = git@github.com:NuCivic/visualization_entity_charts.git
projects[visualization_entity_charts][download][branch] = master


; Performance
; ===========
projects[] = expire
projects[] = memcache
projects[] = entitycache
projects[] = admin_views

; Security
; ==========
projects[] = securepages

; Other
; ======
projects[] = google_analytics
projects[] = migrate
projects[] = entity
