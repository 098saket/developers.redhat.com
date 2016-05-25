require 'fileutils'
require_relative 'test_helper'
require_relative '../scripts/drupal_install_checker'

class DrupalInstallCheckerTest < Minitest::Test
  def test_settings_exists_when_true
    drupal_site = Dir.mktmpdir
    settings_file = File.join drupal_site, 'settings.php'

    begin
      FileUtils.touch settings_file
      cut = DrupalInstallChecker.new(drupal_site, nil, nil)
      assert cut.settings_exists?
    ensure
      FileUtils.remove_entry_secure drupal_site
    end
  end

  def test_settings_exists_when_false
    drupal_site = Dir.mktmpdir

    begin
      cut = DrupalInstallChecker.new(drupal_site, nil, nil)
      refute cut.settings_exists?
    ensure
      FileUtils.remove_entry_secure drupal_site
    end
  end

  def test_rhd_settings_exists_when_true
    drupal_site = Dir.mktmpdir
    settings_file = File.join drupal_site, 'rhd.settings.php'

    begin
      FileUtils.touch settings_file
      cut = DrupalInstallChecker.new(drupal_site, nil, nil)
      assert cut.rhd_settings_exists?
    ensure
      FileUtils.remove_entry_secure drupal_site
    end
  end

  def test_rhd_settings_exists_when_false
    drupal_site = Dir.mktmpdir

    begin
      cut = DrupalInstallChecker.new(drupal_site, nil, nil)
      refute cut.rhd_settings_exists?
    ensure
      FileUtils.remove_entry_secure drupal_site
    end
  end

  def test_mysql_connect_when_true
    process_exec = Minitest::Mock.new
    process_exec.expect :exec!, true, ['mysql', ['--host=example.com', '--port=3306',
                                                 '--user=test', '--password=password',
                                                 '--connect-timeout=20', 'drupal']]
    cut = DrupalInstallChecker.new(nil, process_exec, yaml_opts)

    result = cut.mysql_connect?
    assert process_exec.verify
    assert result
  end

  def test_mysql_connect_when_false
    process_exec = Minitest::Mock.new
    process_exec.expect(:exec!, false) do |db, args|
      raise 'Cannot connect to db'
    end
    cut = DrupalInstallChecker.new(nil, process_exec, yaml_opts)

    result = cut.mysql_connect?
    assert process_exec.verify
    refute result, 'Expected false, got true'
  end

  def test_tables_exists_when_true
    process_exec = Minitest::Mock.new
    tables_to_expect = "Tables_in_drupal\nbatch\nblock_content\nblock_content__body\nblock_content_field_data\nblock_content_field_revision\nblock_content_revision\nblock_content_revision__body\ncache_bootstrap\ncache_config\ncache_container\ncache_data\ncache_default\ncache_discovery\ncache_dynamic_page_cache\ncache_entity\ncache_menu\ncache_render\ncache_rest\ncache_toolbar\ncachetags\ncomment\ncomment__comment_body\ncomment_entity_statistics\ncomment_field_data\nconfig\nfile_managed\nfile_usage\nflood\nhistory\nkey_value\nkey_value_expire\nmenu_link_content\nmenu_link_content_data\nmenu_tree\nnode\nnode__body\nnode__comment\nnode__field_blue_card_description\nnode__field_blue_card_links\nnode__field_blue_card_title\nnode__field_bottom_left_white_card\nnode__field_bottom_right_white_card\nnode__field_container_external_link\nnode__field_container_tags\nnode__field_containers_short_summary\nnode__field_description\nnode__field_green_card\nnode__field_grey_card\nnode__field_id\nnode__field_image\nnode__field_orange_card\nnode__field_solution_name\nnode__field_solution_tag_line\nnode__field_tags\nnode__field_top_left_white_card\nnode__field_top_right_white_card\nnode__field_topic_sub_title\nnode_access\nnode_field_data\nnode_field_revision\nnode_revision\nnode_revision__body\nnode_revision__comment\nnode_revision__field_blue_card_description\nnode_revision__field_blue_card_links\nnode_revision__field_blue_card_title\nnode_revision__field_bottom_left_white_card\nnode_revision__field_bottom_right_white_card\nnode_revision__field_container_external_link\nnode_revision__field_container_tags\nnode_revision__field_containers_short_summary\nnode_revision__field_description\nnode_revision__field_green_card\nnode_revision__field_grey_card\nnode_revision__field_id\nnode_revision__field_image\nnode_revision__field_orange_card\nnode_revision__field_solution_name\nnode_revision__field_solution_tag_line\nnode_revision__field_tags\nnode_revision__field_top_left_white_card\nnode_revision__field_top_right_white_card\nnode_revision__field_topic_sub_title\nqueue\nrouter\nsearch_dataset\nsearch_index\nsearch_total\nsemaphore\nsequences\nsessions\nshortcut\nshortcut_field_data\nshortcut_set_users\ntaxonomy_index\ntaxonomy_term_data\ntaxonomy_term_field_data\ntaxonomy_term_hierarchy\nurl_alias\nuser__roles\nuser__user_picture\nusers\nusers_data\nusers_field_data\nwatchdog\n"
    process_exec.expect :exec!, tables_to_expect, ['mysql', ['--host=example.com', '--port=3306',
                                                             '--user=test', '--password=password',
                                                             '--execute=show tables', 'drupal']]
    cut = DrupalInstallChecker.new(nil, process_exec, yaml_opts)

    result = cut.tables_exists?
    assert process_exec.verify
    assert result, 'Expected true, returned false'
  end

  def test_tables_exists_when_false
    process_exec = Minitest::Mock.new
    process_exec.expect :exec!, '', ['mysql', ['--host=example.com', '--port=3306',
                                               '--user=test', '--password=password',
                                               '--execute=show tables', 'drupal']]
    cut = DrupalInstallChecker.new(nil, process_exec, yaml_opts)

    result = cut.tables_exists?
    assert process_exec.verify
    refute result, 'Expected false, returned true'
  end

  def test_installed_when_true
    process_exec = Minitest::Mock.new
    tables_to_expect = "Tables_in_drupal\nbatch\nblock_content\nblock_content__body\nblock_content_field_data\nblock_content_field_revision\nblock_content_revision\nblock_content_revision__body\ncache_bootstrap\ncache_config\ncache_container\ncache_data\ncache_default\ncache_discovery\ncache_dynamic_page_cache\ncache_entity\ncache_menu\ncache_render\ncache_rest\ncache_toolbar\ncachetags\ncomment\ncomment__comment_body\ncomment_entity_statistics\ncomment_field_data\nconfig\nfile_managed\nfile_usage\nflood\nhistory\nkey_value\nkey_value_expire\nmenu_link_content\nmenu_link_content_data\nmenu_tree\nnode\nnode__body\nnode__comment\nnode__field_blue_card_description\nnode__field_blue_card_links\nnode__field_blue_card_title\nnode__field_bottom_left_white_card\nnode__field_bottom_right_white_card\nnode__field_container_external_link\nnode__field_container_tags\nnode__field_containers_short_summary\nnode__field_description\nnode__field_green_card\nnode__field_grey_card\nnode__field_id\nnode__field_image\nnode__field_orange_card\nnode__field_solution_name\nnode__field_solution_tag_line\nnode__field_tags\nnode__field_top_left_white_card\nnode__field_top_right_white_card\nnode__field_topic_sub_title\nnode_access\nnode_field_data\nnode_field_revision\nnode_revision\nnode_revision__body\nnode_revision__comment\nnode_revision__field_blue_card_description\nnode_revision__field_blue_card_links\nnode_revision__field_blue_card_title\nnode_revision__field_bottom_left_white_card\nnode_revision__field_bottom_right_white_card\nnode_revision__field_container_external_link\nnode_revision__field_container_tags\nnode_revision__field_containers_short_summary\nnode_revision__field_description\nnode_revision__field_green_card\nnode_revision__field_grey_card\nnode_revision__field_id\nnode_revision__field_image\nnode_revision__field_orange_card\nnode_revision__field_solution_name\nnode_revision__field_solution_tag_line\nnode_revision__field_tags\nnode_revision__field_top_left_white_card\nnode_revision__field_top_right_white_card\nnode_revision__field_topic_sub_title\nqueue\nrouter\nsearch_dataset\nsearch_index\nsearch_total\nsemaphore\nsequences\nsessions\nshortcut\nshortcut_field_data\nshortcut_set_users\ntaxonomy_index\ntaxonomy_term_data\ntaxonomy_term_field_data\ntaxonomy_term_hierarchy\nurl_alias\nuser__roles\nuser__user_picture\nusers\nusers_data\nusers_field_data\nwatchdog\n"
    process_exec.expect :exec!, true, ['mysql', ['--host=example.com', '--port=3306',
                                                 '--user=test', '--password=password',
                                                 '--connect-timeout=20', 'drupal']]
    process_exec.expect :exec!, tables_to_expect, ['mysql', ['--host=example.com', '--port=3306',
                                                             '--user=test', '--password=password',
                                                             '--execute=show tables', 'drupal']]

    drupal_site = Dir.mktmpdir
    settings_file = File.join drupal_site, 'settings.php'
    rhd_settings_file = File.join drupal_site, 'rhd.settings.php'

    cut = DrupalInstallChecker.new(drupal_site, process_exec, yaml_opts)

    begin
      FileUtils.touch settings_file
      FileUtils.touch rhd_settings_file

      result = cut.installed?

      assert process_exec.verify
      assert result
    ensure
      FileUtils.remove_entry_secure drupal_site
    end
  end

  def yaml_opts
    opts = <<yml
database:
  host:  example.com
  port: '3306'
  username: 'test'
  password: 'password'
  database: 'drupal'
yml
    YAML.load opts
  end

  private :yaml_opts
end
