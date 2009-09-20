ad_page_contract {

    @author Frank Bergmann frank.bergmann@project-open.com
    @creation-date 2009-09-04
    @cvs-id $Id$

} {
    {orderby "name"}
}

# ------------------------------------------------------------------
# Default & Security
# ------------------------------------------------------------------

set page_title [lang::message::lookup "" intranet-cvs-integration.CVS_Integration "CVS Integration"]
set context_bar [im_context_bar [list /intranet-cvs-integration/ "CVS Integration"] $page_title]

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

# ------------------------------------------------------------------
# 
# ------------------------------------------------------------------

set bulk_action_list [list \
	"[lang::message::lookup {} intranet-dynfield.Full_Import {Full Import}]" "action-full-import" "" \
]


list::create \
    -name cvs_repositories \
    -multirow cvs_repositories \
    -key repository_id \
    -row_pretty_plural "[lang::message::lookup {} intranet-cvs-integration.CVS_Repositories {CVS Repositories}]" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -actions {
    } -bulk_actions $bulk_action_list \
    -bulk_action_export_vars {
        repository_id
    } -elements {
        repository_name {
            label "[lang::message::lookup {} intranet-cvs-integration.Repository {Repository}]"
            link_url_eval $repository_url
        }
        cvs_user {
            label "[lang::message::lookup {} intranet-cvs-integration.CVS_User {User}]"
        }
        cvs_hostname {
            label "[lang::message::lookup {} intranet-cvs-integration.CVS_Hostname {Hostname}]"
        }
        cvs_port {
            label "[lang::message::lookup {} intranet-cvs-integration.CVS_Port {Port}]"
        }
        cvs_path {
            label "[lang::message::lookup {} intranet-cvs-integration.CVS_Path {Path}]"
        }
        cvs_password {
            label "[lang::message::lookup {} intranet-cvs-integration.CVS_Password {Password}]"
        }
        num_commits {
            label "[lang::message::lookup {} intranet-cvs-integration.Num_Commits Commits]"
        }
    }


db_multirow -extend { repository_url } cvs_repositories select_cvs_repositories {
	select	conf_item_id as repository_id,
		conf_item_name as repository_name,
		cvs_user,
		cvs_password,
		cvs_hostname,
		cvs_port,
		cvs_path,
		conf_item_nr as repository,
		stats.*
	from	im_conf_items ci
		LEFT OUTER JOIN (
			select	count(*) as num_commits,
				cvs_project as repository
			from	im_cvs_activity
			group by repository
		) stats ON ci.conf_item_nr = stats.repository
	where	cvs_path is not NULL
	order by
		lower(conf_item_name)
} {
    set repository_url [export_vars -base "/intranet-confdb/new" {{conf_item_id $repository_id}}]
}


ad_return_template