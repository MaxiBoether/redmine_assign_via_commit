This plug-in allows you to change the assignee via your commit message.

Examples:

  This commit refs #1, #2 and fixes #3 >JohnDoe
  Implement feature #1234 @2h >JohnDoe

Implementation:

  This plug in patches a hook into ``scan_for_issues`` of the Redmine
  model ``Changeset`` (for future flexibility) and then attaches a
  listener to that hook to parse commit message.
