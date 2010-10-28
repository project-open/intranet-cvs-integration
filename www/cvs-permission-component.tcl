# Portlet for object permissions
# conf_item_id:integer

set current_user_id [ad_conn user_id]
if { ![exists_and_not_null return_url] } { set return_url [ad_return_url] }
if {![info exists conf_item_id]} { set conf_item_id "" }


set object_id $conf_item_id
if {"" == $object_id} { set object_id  [ad_conn subsite_id] }



set current_user_id [ad_get_user_id]
im_conf_item_permissions $current_user_id $object_id view read write admin

# if {!$admin} { ad_return_complaint 1 "You don't have the necessary permissions to modify this objects" }

set perm_url "/intranet-cvs-integration/permissions/"
set perm_modify_url "${perm_url}perm-modify"

if { ![exists_and_not_null privs] } { set privs { read create write admin } }

# Get information about the object
db_1row object_info {}

set page_title [lang::message::lookup "" intranet-cvs-integration.Object_Permissions "%object_name% Permissions"]

set elements [list]
lappend elements grantee_name { 
    label "[_ acs-subsite.Name]" 
    link_url_col name_url
    display_template {
        <if @permissions.any_perm_p_@ true>
          @permissions.grantee_name@
        </if>
        <else>
          <font color="gray">@permissions.grantee_name@</font>
        </else>
    }
}

foreach priv $privs { 
    lappend select_clauses "sum(ptab.${priv}_p) as ${priv}_p"
    lappend select_clauses "(case when sum(ptab.${priv}_p) > 0 then 'checked' else '' end) as ${priv}_checked"
    lappend from_all_clauses "(case when privilege='${priv}' then 2 else 0 end) as ${priv}_p"
    lappend from_direct_clauses "(case when privilege='${priv}' then -1 else 0 end) as ${priv}_p"
    lappend from_dummy_clauses "0 as ${priv}_p"

    lappend elements ${priv}_p \
        [list \
             html { align center } \
             label [string totitle [string map {_ { }} $priv]] \
             display_template "
               <if @permissions.${priv}_p@ ge 2>
                 <img src=\"/shared/images/checkboxchecked\" border=\"0\" height=\"13\" width=\"13\" alt=\"X\" title=\"This permission is inherited, to remove, click the 'Do not inherit ...' button above.\">
               </if>
               <else>
                 <input type=\"checkbox\" name=\"perm\" value=\"@permissions.grantee_id@,${priv}\" @permissions.${priv}_checked@>
               </else>
             " \
            ]
}

# Remove all
lappend elements remove_all {
    html { align center } 
    label "[_ acs-subsite.Remove_All]"
    display_template {<input type="checkbox" name="perm" value="@permissions.grantee_id@,remove">}
}




if { ![exists_and_not_null user_add_url] } {
    set user_add_url "${perm_url}perm-user-add"
}
set user_add_url [export_vars -base $user_add_url { object_id expanded {return_url "[ad_return_url]"}}]


set actions [list "[_ acs-subsite.Grant_Permission]" "${perm_url}grant?[export_vars {return_url application_url object_id}]" "[_ acs-subsite.Grant_Permission]" "[_ acs-subsite.Search_For_Exist_User]" $user_add_url "[_ acs-subsite.Search_For_Exist_User]"]
				
if { ![empty_string_p $context_id] } {
    set inherit_p [permission::inherit_p -object_id $object_id]

    if { $inherit_p } {
        lappend actions "Do not inherit from $parent_object_name" [export_vars -base "${perm_url}toggle-inherit" {object_id {return_url [ad_return_url]}}] "Stop inheriting permissions from the $parent_object_name"
    } else {
        lappend actions "Inherit from $parent_object_name" [export_vars -base "${perm_url}toggle-inherit" {object_id {return_url [ad_return_url]}}] "Inherit permissions from the $parent_object_name"
    }
}

if {!$admin} { set actions "" }

template::list::create \
    -name permissions \
    -multirow permissions \
    -actions $actions \
    -elements $elements 


set perm_form_export_vars [export_vars -form {object_id privs return_url}]
set application_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]


# PERMISSION: yes = 2, no = 0
# DIRECT:     yes = 1, no = -1

# 3 = permission + direct
# 2 = permission, no direct
# 1 = no permission, but direct (can't happen)
# 0 = no permission


# 2 = has permission, not direct => inherited
# 1 = has permission, it's direct => direct
# -1 = no permission 

# NOTE:
# We do not include site-wide admins in the list

db_multirow -extend { name_url } permissions permissions {} {
    if { [string equal $object_type "user"] && $grantee_id != 0 } {
        set name_url [acs_community_member_url -user_id $grantee_id]
}
}

