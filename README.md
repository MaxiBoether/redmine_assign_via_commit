This plug-in allows you to set the assignee via your commit message
-------------------------------------------------------------------

Simply add a ``>`` and the desired login name after your reference to the
corresponding commit.

Examples
--------

  This commit refs #1, #2 and fixes #3 >johndoe
  Implement feature #1234 @2,5h >johndoe

Implementation
--------------

  This plug in patches a hook into ``scan_for_issues`` of the Redmine
  model ``Changeset`` (for future flexibility) and then attaches a
  listener to that hook to parse commit message.
