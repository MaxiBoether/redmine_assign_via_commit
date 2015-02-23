# coding: utf-8
module RedmineAssignViaCommit
  module Hooks
    class SetAssigneeHook < Redmine::Hook::ViewListener

      def model_changeset_scan_commit_for_issues (context={})
        return unless context[:changeset]
        changeset = context[:changeset]
        commit_msg = changeset.comments

        # regex inspired by the on in
        # Redmine's Changeset.scan_comment_for_issue_ids
        commit_msg.scan(
          /#(\d+)(\s+@#{Changeset::TIMELOG_RE})?\s+>([^\s]+)/
        ).each do |m|

          issue = changeset.find_referenced_issue_by_id(m[0].to_i)
          next unless issue

          new_assignee = User.find_by_login(m[-1])
          next unless new_assignee

          next unless issue.assignable_users.include? new_assignee

          Rails.logger.info "Assigning #{new_assignee.login} to \##{issue.id} because of commit message '#{commit_msg}'."

          issue.assigned_to = new_assignee
          issue.save

        end
      end
    end
  end
end
