; This make file helps package DKAN as well as desired modules, themes, and
; libraries. Use in conjunction with drush subtree or build-manager to track
; and contribute to upstream code.

; Grab DKAN make file
includes[dkan] = build-dkan.make

; Set the default subdirectory for projects so we don't have to specifically set it each time, but make sure dkan stays in /profiles
defaults[projects][subdir] = contrib
projects[dkan][subdir] = ""

; Default Projects
; ================
projects[] = features_master

; Optional Projects
; =================
; These start as all commented out, but you'll probably want to enable almost all of them depending on the project.

; Development
; ===========
;projects[] = devel
;projects[] = environment
;projects[] = maillog
;projects[] = shield
;projects[] = features_override
;projects[] = security_review

; Acquia
; ======
;projects[] = acquia_connector
; Acquia Expire integration
;projects[] = acquia_purge
; Acquia Search modules
;projects[] = search_api_acquia
;projects[] = acquia_search_multi_subs

; Search
; ======
;projects[] = search_api_solr

; VISUALIZATION ENTITY
; =====
projects[visualization_entity][download][type] = git
projects[visualization_entity][download][url] = git@github.com:NuCivic/visualization_entity.git
projects[visualization_entity][download][branch] = master

projects[visualization_entity_charts][download][type] = git
projects[visualization_entity_charts][download][url] = git@github.com:NuCivic/visualization_entity_charts.git
projects[visualization_entity_charts][download][branch] = master

projects[geo_file_entity][subdir] = nucivic
projects[geo_file_entity][download][type] = git
projects[geo_file_entity][download][url] = https://github.com/NuCivic/geo_file_entity.git
projects[geo_file_entity][download][branch] = master
projects[geo_file_entity][type] = module

projects[uuidreference][subdir] = contrib
projects[uuidreference][version] = 1.x-dev
projects[uuidreference][patch][238875] = https://www.drupal.org/files/issues/uuidreference-alternative_to_module_invoke_all_implementation_for_query_alter_hook-238875-0.patch

libraries[chroma][download][type] = "file"
libraries[chroma][download][url] = "https://github.com/gka/chroma.js/zipball/master"

libraries[numeral][download][type] = "file"
libraries[numeral][download][url] = "https://github.com/adamwdraper/Numeral-js/zipball/master"

libraries[recline_choropleth][download][type] = "file"
libraries[recline_choropleth][download][url] = "https://github.com/NuCivic/recline.view.choroplethmap.js/archive/master.zip"

# NVD3
libraries[nvd3][type] = libraries
libraries[nvd3][download][type] = git
libraries[nvd3][download][url] = "https://github.com/novus/nvd3.git"
libraries[nvd3][download][revision] = "7ebd54ca09061022a248bec9a050a4dec93e2b28"

# D3
libraries[d3][type] = libraries
libraries[d3][download][type] = git
libraries[d3][download][url] = "https://github.com/mbostock/d3.git"
libraries[d3][download][revision] = "f82dd6fb414a15bca4f9c39c7c9442295ddea416"

# GDOCS BACKEND
libraries[gdocs][type] = libraries
libraries[gdocs][download][type] = git
libraries[gdocs][download][url] = "https://github.com/okfn/recline.backend.gdocs.git"
libraries[gdocs][download][revision] = "e81bb237759353932834a38a0ec810441e0ada10"

# LODASH DATA
libraries[lodash_data][type] = libraries
libraries[lodash_data][download][type] = git
libraries[lodash_data][download][url] = "https://github.com/NuCivic/lodash.data.git"
libraries[lodash_data][download][revision] = "0dbe0701003b8a45037ab5fada630db2dbf75d9d"

# RECLINE NVD3 VIEW
libraries[reclineViewNvd3][type] = libraries
libraries[reclineViewNvd3][download][type] = git
libraries[reclineViewNvd3][download][url] = "https://github.com/NuCivic/recline.view.nvd3.js.git"
libraries[reclineViewNvd3][download][revision] = "3fd41696114206423c025de9fa655ffac5015d84"

# CHOSEN
libraries[chosen][type] = libraries
libraries[chosen][download][type] = get
libraries[chosen][download][url] = https://github.com/harvesthq/chosen/releases/download/v1.3.0/chosen_v1.3.0.zip
libraries[chosen][destination] = libraries

# CHOSEN BOOTSTRAP
libraries[chosen_bootstrap][type] = libraries
libraries[chosen_bootstrap][download][type] = git
libraries[chosen_bootstrap][download][url] = https://github.com/dbtek/chosen-bootstrap.git
libraries[chosen_bootstrap][destination] = libraries

; Performance
; ===========
;projects[] = expire
;projects[] = memcache
;projects[] = entitycache
;projects[] = admin_views

; Security
; ==========
;projects[] = securepages

; Other
; ======
;projects[] = google_analytics
;projects[] = migrate
;projects[] = entity
