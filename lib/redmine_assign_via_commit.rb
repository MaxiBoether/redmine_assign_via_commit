# install hooks:
Rails.configuration.to_prepare do
  require_dependency 'changeset_patch'
end

# load listeners
require_dependency 'set_assignee_hook_listener'
