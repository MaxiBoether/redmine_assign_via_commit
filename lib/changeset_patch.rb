require_dependency 'changeset'

module RedmineAssignViaCommit
  module Patches
    module ChangesetPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method :scan_for_issues_without_hook, :scan_for_issues
          alias_method :scan_for_issues, :scan_for_issues_with_hook
        end
      end

      module InstanceMethods
        def scan_for_issues_with_hook
          Redmine::Hook.call_hook(:model_changeset_scan_commit_for_issues,
            { :changeset => self })
          return scan_for_issues_without_hook
        end
      end

    end
  end
end

unless Changeset.included_modules.include?(RedmineAssignViaCommit::Patches::ChangesetPatch)
  Changeset.send(:include, RedmineAssignViaCommit::Patches::ChangesetPatch)
end
