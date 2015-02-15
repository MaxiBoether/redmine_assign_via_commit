# coding: utf-8
module RedmineAssignViaCommit
  module Hooks
    class SetAssigneeHook < Redmine::Hook::ViewListener

      def model_changeset_scan_commit_for_issues (context={})

        Rails.logger.info "\n\nSetAssigneeHook called with #{context}\n\n"

        return unless context[:changeset]
        issue = context[:changeset]

        return unless context[:issue]
        issue = context[:issue]

      end
    end
  end
end
