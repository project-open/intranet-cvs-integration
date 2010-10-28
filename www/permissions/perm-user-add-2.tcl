ad_page_contract {} {
    object_id
    user_id:multiple,integer
    return_url
}


set current_user_id [ad_get_user_id]
im_conf_item_permissions $current_user_id $object_id view read write admin
if {!$admin} {
    ad_return_complaint 1 "You don't have the necessary permissions to modify this objects"
}

db_transaction {
    foreach one_user_id $user_id {
        db_exec_plsql add_user {}
    }
} on_error {
    ad_return_complaint 1 "We had a problem adding the users you selected. Sorry."
}

ad_returnredirect $return_url
