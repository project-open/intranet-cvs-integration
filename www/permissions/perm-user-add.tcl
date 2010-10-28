ad_page_contract {
    Simple page for adding users to permissions list.
} {
    return_url
}

set context [list [list $return_url "Permissions"] "Add User"]
set title "Add User"


set current_user_id [ad_get_user_id]
im_conf_item_permissions $current_user_id $object_id view read write admin
if {!$admin} {
    ad_return_complaint 1 "You don't have the necessary permissions to modify this objects"
}

