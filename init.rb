# coding: utf-8
require 'redmine'

require 'redmine_assign_via_commit'

Redmine::Plugin.register :redmine_assign_via_commit do
  name 'Assign via Commit'
  author 'Lukas Pirl'
  description 'This plug in provides more actions that can be triggered from commit messages.'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.6.0'
end
