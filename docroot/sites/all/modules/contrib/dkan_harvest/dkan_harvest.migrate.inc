<?php

/**
 * @file
 * Migration File for DKAN Harvest.
 */


/**
 * Implements hook_migrate_api().
 */
function dkan_harvest_migrate_api() {
  $api = array(
    'api' => 2,
    'groups' => array(
      'dkan_harvest' => array(
        'title' => t('dkan_harvest'),
      ),
    ),
    'migrations' => array(
      'dkan_harvest_data_json' => array(
        'class_name' => 'DataJSONHarvest',
        'group_name' => 'dkan_harvest',
        'title' => t('data.json harvest'),
      ),
    ),
  );
  return $api;
}

class DataJSONList extends MigrateList {
  protected $files;
  /**
   * Builds the list of files paths inside DKAN_HARVEST_CACHE_DIR.
   */
  public function __construct() {
    parent::__construct();
    // Build list of items based off sources definitions.
    if (!isset($this->files)) {
      $files = array();
      $sources = dkan_harvest_sources_definition();
      foreach ($sources as $key => $source) {
        if ($source['type'] == 'data.json') {
          $dir = DKAN_HARVEST_CACHE_DIR . '/' . $key;
          $dir = drupal_realpath($dir);
          foreach (glob($dir . '/*') as $filename) {
            if (!in_array(pathinfo($filename)['filename'], array('.', '..'))) {
              $files[] = $filename;
            }
          }
        }
      }
      $this->files = $files;
    }
  }
  /**
   * Implements MigrateList::getIdList().
   */
  public function getIdList() {
    return $this->files;
  }

  /**
   * Implements MigrateList::__toString().
   */
  public function __toString() {
    return '';
  }

  /**
   * Implements MigrateList::computeCount().
   */
  public function computeCount() {
    return count($this->getIdList());
  }
}

class DataJSONItem extends MigrateItem {
  /**
   * Implements MigrateItem::getItem().
   */
  public function getItem($id) {

    $json = file_get_contents($id);
    $migration = Migration::currentMigration();
    // Test if file exists.
    if ($json === FALSE) {
      $message = t('Loading of !objecturl failed:', array('!objecturl' => $id));
      $migration->getMap()->saveMessage(array($id), $message, MigrationBase::MESSAGE_ERROR);
      return new stdClass();
    }
    // Test if file is valid json.
    $json = drupal_json_decode($json);
    if (is_null($json)) {
      $message = t('!objecturl does not contain a valid json string:', array('!objecturl' => $id));
      $migration->getMap()->saveMessage(array($id), $message, MigrationBase::MESSAGE_ERROR);
      return new stdClass();
    }

    // Validate that source is set properly for item.
    $key = explode('/', $id);
    end($key);
    $key = prev($key);
    $sources = dkan_harvest_sources_definition();
    if (!isset($sources[$key])) {
      $message = t('!objecturl does not belong to a valid harvest source:', array('!objecturl' => $id));
      $migration->getMap()->saveMessage(array($id), $message, MigrationBase::MESSAGE_ERROR);
      return new stdClass();
    }
    $source = $sources[$key];
    // Set key to ease item identification while processing the row.
    $json['source'] = $key;
    // Set defaults.
    if (isset($source['defaults'])) {
      foreach ($source['defaults'] as $default => $value) {
        $json[$default] = $value;
      }
    }
    // Set overrides.
    foreach ($source['overrides'] as $override => $value) {
      $json[$override] = $value;
    }
    $message = t('!objecturl prepared for data json migration', array('!objecturl' => $id));
    $migration->getMap()->saveMessage(array($id), $message, MigrationBase::MESSAGE_INFORMATIONAL);
    return (object) $json;
  }
}

class DataJSONHarvest extends MigrateDKAN {
  /**
   * Registers endpoints.
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $this->source = new MigrateSourceList(
      new DataJSONList(),
      new DataJSONItem()
    );
    $this->map = new MigrateSQLMap(
        $this->machineName,
        array(
          'uuid' => array(
            'type' => 'varchar',
            'length' => 255,
            'not null' => TRUE,
            'description' => 'id',
          ),
        ),
        MigrateDestinationNode::getKeySchema()
    );
    $this->destination = new MigrateDestinationNode(
      'dataset',
      array('text_format' => 'html')
    );
    $mappings = $this->getBaseMappings();
    foreach ($mappings as $key => $map) {
      $this->addFieldMapping($map, $key);
    }
  }

  protected function getBaseMappings() {
    return array(
      'uid' => 'uid',
      'title' => 'title',
      'description' => 'body',
      'issued' => 'created',
      'keywords' => 'field_tags',
      'resources' => 'field_resources',
      'field_additional_info_key' => 'field_additional_info',
      'field_additional_info_value' => 'field_additional_info:second',
    );
  }

  /**
   * Implements prepareRow.
   */
  public function prepareRow($row) {
    $existing = db_query(
      'SELECT nid FROM {node} WHERE title = :title',
      array(':title' => $row->title)
    )->fetchField();
    if (is_numeric($existing)) {
      $row->existing = node_load($existing);
    }
    $row->uid = 1;
    // $row->identifier = $this->prepareIdentifier($row->identifier);
    $row->keywords = $this->prepareKeywords($row);
    $row->resources = $this->prepareResources($row);
    $this->prepareAdditionalInfo($row);
  }

  public function prepareAdditionalInfo(&$row) {
    $ignore = array(
      'distribution',
      'keyword',
      'uuid',
      'resources',
      'keywords',
      'existing',
      'migrate_map_sourceid1',
      'migrate_map_destid1',
      'migrate_map_needs_update',
      'migrate_map_rollback_action',
      'migrate_map_last_imported',
      'migrate_map_hash',
    );
    $mapped_fields = array_keys($this->getBaseMappings());
    $row_keys = (array) $row;
    $row_keys = array_keys($row_keys);
    foreach ($row_keys as $key) {
      if (!in_array($key, $mapped_fields) && !in_array($key, $ignore)) {
        if (is_object($row->{$key}) || is_array($row->$key)) {
          foreach ((array) $row->{$key} as $k => $v) {
            if ($k != '@type') {
              $k = $key . '-' . $k;
              $row->field_additional_info_key[] = substr($k, 0, 254);
              $row->field_additional_info_value[] = substr($v, 0, 254);
            }
          }
        }
        else {
          $row->field_additional_info_key[] = substr($key, 0, 254);
          $row->field_additional_info_value[] = substr($row->{$key}, 0, 254);
        }
      }
    }
  }

  /**
   * Prepare Keywords.
   */
  public function prepareKeywords($row) {
    $keywords = array();
    $tags = taxonomy_vocabulary_machine_name_load('tags');
    if (isset($row->keyword)) {
      foreach ($row->keyword as $keyword) {
        $tag = $this->createTax($keyword, 'tags', $tags->vid);
        $keywords[] = $tag->name;
      }
    }
    return $keywords;
  }

  /**
   * Prepare Resources.
   */
  public function prepareResources($row) {
    $resources = array();
    if ($row->existing && isset($row->existing->field_resources[LANGUAGE_NONE])) {
      foreach ($row->existing->field_resources[LANGUAGE_NONE] as $resource) {
        $resource = node_load($resource['target_id']);
        if (isset($resource->field_link_api[LANGUAGE_NONE]) && count($resource->field_link_api[LANGUAGE_NONE])) {
          $url = $resource->field_link_api[LANGUAGE_NONE][0]['url'];
          foreach ($row->distribution as $key => $new_resource) {
            if ($new_resource['downloadURL'] == $url) {
              unset($row->distribution[$key]);
              $resources[] = $resource->nid;
              $this->map->saveIDMapping($resource, array($resource->nid), 0, 0, '');
            }
          }
        }
      }
    }
    if (isset($row->distribution)) {
      foreach ($row->distribution as $resource) {
        $res = new stdClass();
        $res->name = isset($resource['name']) ? $resource['name'] : $row->title;
        // Provide default for distribution items with absent name property.
        if (isset($resource['mediaType']) && $res->name == $row->title) {
          $res->format = recline_get_data_type($resource['mediaType']);
          $res->name = $res->name . ' - ' . $res->format;
        }
        $res->url = $resource['downloadURL'];
        $resource = $this->createResourceNode($res);
        $resources[] = $resource->nid;
      }
    }
    return $resources;
  }

  /**
   * Prepare Identifier.
   */
  public function prepareIdentifier($identifier) {
    if (filter_var($identifier, FILTER_VALIDATE_URL)) {
      $host = parse_url($identifier, PHP_URL_HOST);
      $identifier = parse_url($identifier, PHP_URL_PATH);
      $identifier = explode('/', $identifier);
      $identifier = end($identifier);
      $identifier = $host . '--' . $identifier;
    }
    return $identifier;
  }

  /**
   * Implements prepare.
   */
  public function prepare($node, stdClass $row) {
    if (isset($row->existing)) {
      $node->nid = $row->existing->nid;
    }
  }

  /**
   * Implements complete.
   */
  public function complete($node, stdClass $node) {}
}
