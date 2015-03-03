# coding: utf-8
module RedmineAssignViaCommit
  module Hooks
    class SetAssigneeHook < Redmine::Hook::ViewListener

      FALLBACK_LOGIN_RE = /[a-z0-9_\-@\.]*/i

      def model_changeset_scan_commit_for_issues (context={})
        return unless context[:changeset]
        changeset = context[:changeset]
        commit_msg = changeset.comments

        login_format_validators = User.validators_on(:login).select{ |v|
          v.is_a? ActiveModel::Validations::FormatValidator
        }

        login_re = nil
        if login_format_validators.length == 1
          begin
            login_re = login_format_validators[0].options[:with]
          rescue NoMethodError
            Rails.logger.error "Could not get regex from FormatValidator for User.login"
          end
        else
          Rails.logger.error "Found multiple FormatValidators for User.login"
        end

        if !login_re
          Rails.logger.error "Cannot reliably determine regex to " +
            "detect login names. Using a fallback. Please file a bug " +
            "report for the redmine_assign_via_commit plugin."
          login_re = FALLBACK_LOGIN_RE
        else
          # remove the condition "beginning of string" and "end of string"
          login_re_s = login_re.to_s
          login_re_s["\\A"] = ""
          login_re_s["\\z"] = ""
          login_re = Regexp.new login_re_s
        end

        # regex inspired by the on in
        # Redmine's Changeset.scan_comment_for_issue_ids
        commit_msg.scan(
          /#(\d+)(\s+@#{Changeset::TIMELOG_RE})?\s+>(#{login_re})/
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
