# coding: utf-8
module RedmineAssignViaCommit
  module Hooks
    class SetAssigneeHook < Redmine::Hook::ViewListener

      FALLBACK_LOGIN_RE = /[a-z0-9_\-@\.]*/i

      def model_changeset_scan_commit_for_issues (context={})
        return unless context[:changeset]
        changeset = context[:changeset]
        commit_msg = changeset.comments

        # skip if importing old commits
        repository_created_on = changeset.repository.created_on
        changeset_committed_on = changeset.committed_on
        return unless repository_created_on &&
                      changeset_committed_on &&
                      repository_created_on < changeset_committed_on

        # get validator of Redmine's User model
        login_format_validators = User.validators_on(:login).select{ |v|
          v.is_a? ActiveModel::Validations::FormatValidator
        }

        # get regex from validator
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
          # use fallback regex if not retrievable from validator
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
          /((?:\s+#\d+)+)(\s+@#{Changeset::TIMELOG_RE})?\s+>(#{login_re})/i
        ).each do |m|
          Rails.logger.info "Commit message '#{commit_msg}' matches format to set a new assignee."

          new_assignee = User.find_by_login(m[-1])
          if not new_assignee
            Rails.logger.info "Cannot find user #{m[-1]}."
            next
          end

          m[0].split("#").drop(1).each do |issue_id_s|

            issue_id = issue_id_s.to_i
            issue = changeset.find_referenced_issue_by_id(issue_id)
            if not issue
              Rails.logger.info "Cannot find issue \##{issue_id}."
              next
            end

            if not issue.assignable_users.include? new_assignee
              Rails.logger.info "User #{new_assignee.login} not assignable to issue \##{issue.id}."
              next
            end

            # skip if nothing changes
            if issue.assigned_to == new_assignee
              Rails.logger.info "User #{new_assignee.login} already assigned to issue \##{issue.id}."
              next
            end

            Rails.logger.info "Assigning #{new_assignee.login} to \##{issue.id}."

            issue.init_journal(
              changeset.user || User.anonymous,
              ll(
                Setting.default_language,
                :text_status_changed_by_changeset,
                changeset.text_tag(issue.project)
              )
            )

            issue.assigned_to = new_assignee
            issue.save
          end
        end
      end
    end
  end
end
