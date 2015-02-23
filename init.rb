# coding: utf-8
require 'redmine'

require 'redmine_assign_via_commit'

Redmine::Plugin.register :redmine_assign_via_commit do
  name 'Assign via Commit'
  author 'Lukas Pirl'
  description 'Set an issue\'s assignee by commit message.'
  version '0.0.1'
  url 'https://github.com/lpirl/redmine_assign_via_commit'
  requires_redmine :version_or_higher => '2.6.0'
end
