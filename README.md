# ]po[ CVS Integration
This package is part of ]project-open[, an open-source enterprise project management system.

For more information about ]project-open[ please see:
* [Documentation Wiki](http://www.project-open.com/en/)
* [V5.0 Download](https://sourceforge.net/projects/project-open/files/project-open/V5.0/)
* [Installation Instructions](http://www.project-open.com/en/list-installers)

About ]po[ CVS Integration:

<p><p><p>This package integrates CVS with ]project-open[. In the future, it will also support SVN and other version control systems. <p><p><ul><li>Periodically parses the CVS &quot;log&quot; and imports commits of selected CVS repositories. <li>Associates commits with ]po[ users by mapping CVS users to ]po[ users.<li>Associates commits with ]po[ <a href="/en/object-type-im-conf-item">configuration items</a> in order to maintain a commit history. <li>Associates commits to <a href="/en/object-type-im-project">projects</a> and <a href="/en/object-type-im-ticket">tickets</a> by checking the comments for &quot;#123&quot; ticket IDs or &quot;#2008_2123&quot; project numbers. <li>Closes a ticket if the commit comment includes a string like &quot;fixed #123&quot;. </ul><p><p><p>As of today (2009-09-16): <ul><li>Only CVS is supported at the moment. <li>The association with users and projects don&#39;t work yet. <li>The association with conf items doesn&#39;t work yet. </ul><p>

# Online Reference Documentation

## Main Activities



## Package Status



