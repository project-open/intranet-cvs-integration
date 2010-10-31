-- /packages/intranet-cvs-integration/sql/postgresql/intranet-cvs-integration.sql
--
-- Copyright (c) 2003-2006 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


-----------------------------------------------------------
-- Integrate with CVS
--
-- We setup a database table to be filled with records
-- being returned from the CVS "rlog" command
-- Together with the "cvs_user" field in "persons"
-- this allows us to track how many lines have been
-- written on what project by a developer.

create sequence im_cvs_logs_seq start 1;
create table im_cvs_logs (
	cvs_line_id		integer
				constraint im_cvs_logs_pk
				primary key,
	cvs_repo		text,
	cvs_filename		text,
	cvs_revision		text,
	cvs_date		timestamptz,
	cvs_author		text,
	cvs_state		text,
	cvs_lines_add		integer,
	cvs_lines_del		integer,
	cvs_note		text,
	
	cvs_user_id		integer,
	cvs_project_id		integer,
	cvs_conf_item_id	integer,

		constraint im_cvs_logs_filname_un
		unique (cvs_filename, cvs_date, cvs_revision)
);



-----------------------------------------------------------
-- DynFields
--
-- Define fields necessary for CVS repository access


alter table persons add cvs_user text;


alter table im_conf_items add cvs_system text;
alter table im_conf_items add cvs_protocol text;
alter table im_conf_items add cvs_user text;
alter table im_conf_items add cvs_password text;
alter table im_conf_items add cvs_hostname text;
alter table im_conf_items add cvs_port integer;
alter table im_conf_items add cvs_path text;


SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_system', 'CVS System', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_protocol', 'CVS Protocol', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_user', 'CVS User', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_password', 'CVS Password', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_hostname', 'CVS Hostname', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_port', 'CVS Port', 'integer', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_conf_item', 'cvs_path', 'CVS Path', 'textbox_medium', 'string', 'f');







-----------------------------------------------------------
-- Create a new Group Type to represent CVS groups
--
-- Implement a new group_type called "CVS group" to implement
-- the management of the ]po[ CVS ACL repository.
-- This works by defining the CVS ACL groups and their membership
-- in ]po[. A Perl script will query these using the REST interface.
-----------------------------------------------------------

select acs_object_type__create_type (
	'im_cvs_group',
	'CVS Group',
	'CVS Groups',
	'group',
	'IM_CVS_GROUP_EXT',
	'GROUP_ID',
	'im_cvs_group',
	'f',
	null,
	null
);

insert into acs_object_type_tables VALUES ('im_cvs_group', 'im_cvs_group_ext', 'group_id');

-- Mark ticket_queue as a dynamically managed object type
update acs_object_types 
set dynamic_p='t' 
where object_type = 'im_cvs_group';


-- Copy group type_rels to queues
insert into group_type_rels (group_rel_type_id, rel_type, group_type)
select	nextval('t_acs_object_id_seq'), 
	r.rel_type, 
	'im_cvs_group'
from	group_type_rels r
where	r.group_type = 'group';


create table im_cvs_group_ext (
	group_id	integer
			constraint im_cvs_group_ext_group_pk primary key
			constraint im_cvs_group_ext_group_fk references groups (group_id)
);


select define_function_args('im_cvs_group__new','GROUP_ID,GROUP_NAME,EMAIL,URL,LAST_MODIFIED;now(),MODIFYING_IP,OBJECT_TYPE;im_cvs_group,CONTEXT_ID,CREATION_USER,CREATION_DATE;now(),CREATION_IP,JOIN_POLICY');

create function im_cvs_group__new(INT4,VARCHAR,VARCHAR,VARCHAR,TIMESTAMPTZ,VARCHAR,VARCHAR,INT4,INT4,TIMESTAMPTZ,VARCHAR,VARCHAR)
returns INT4 as '
declare
	p_GROUP_ID		alias for $1;
	p_GROUP_NAME		alias for $2;
	p_EMAIL			alias for $3;
	p_URL			alias for $4;
	p_LAST_MODIFIED		alias for $5;
	p_MODIFYING_IP		alias for $6;

	p_OBJECT_TYPE		alias for $7;
	p_CONTEXT_ID		alias for $8;
	p_CREATION_USER		alias for $9;
	p_CREATION_DATE		alias for $10;
	p_CREATION_IP		alias for $11;
	p_JOIN_POLICY		alias for $12;

	v_GROUP_ID 		IM_CVS_GROUP_EXT.GROUP_ID%TYPE;
begin
	v_GROUP_ID := acs_group__new (
		p_group_id,p_OBJECT_TYPE,
		p_CREATION_DATE,p_CREATION_USER,
		p_CREATION_IP,p_EMAIL,
		p_URL,p_GROUP_NAME,
		p_JOIN_POLICY,p_CONTEXT_ID
	);
	insert into IM_CVS_GROUP_EXT (GROUP_ID) values (v_GROUP_ID);
	return v_GROUP_ID;
end;' language 'plpgsql';

create function im_cvs_group__delete (INT4)
returns integer as '
declare
	p_GROUP_ID	alias for $1;
begin
	perform acs_group__delete( p_GROUP_ID );
	return 1;
end;' language 'plpgsql';


-- Create some groups for ]po[
--
create or replace function inline_0 ()
returns integer as $body$
declare
	row			RECORD;
	v_count			integer;
BEGIN
	FOR row IN
			select 'readall' as group_name
		UNION	select 'admin' as group_name
		UNION	select 'anon' as group_name
		UNION	select 'cost_center' as group_name
		UNION	select 'cost_audit' as group_name
		UNION	select 'freelance' as group_name
		UNION	select 'freelance_rfqs' as group_name
		UNION	select 'reporting_finance' as group_name
		UNION	select 'reporting_cubes' as group_name
		UNION	select 'reporting_translation' as group_name
		UNION	select 'trans_quality' as group_name
		UNION	select 'cognovis' as group_name
	LOOP
		select count(*) into v_count from groups where group_name = row.group_name;
		IF v_count = 0 THEN 
			PERFORM im_cvs_group__new(null, row.group_name, NULL, NULL, now(), NULL, 'im_cvs_group', null, 0, now(), '0.0.0.0', NULL); 
		END IF;
	END LOOP;

	return 0;
end; $body$ language 'plpgsql';
select inline_0();
drop function inline_0();





-- Create a Group Type portlet in the user's page
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'CVS ACL Group Administration',	-- plugin_name
	'intranet-cvs-integration',	-- package_name
	'right',			-- location
	'/intranet/users/view',		-- page_url
	null,				-- view_name
	30,				-- sort_order
	'im_group_type_component -group_type im_cvs_group -user_id $user_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cvs-integration.CVS_ACL_Group_Admin "CVS ACL Group Administration"'
where plugin_name = 'CVS ACL Group Administration';








-----------------------------------------------------------
-- Menu for CVS Administration
--
-- Create a menu item in the main menu bar and set some default 
-- permissions for various groups who should be able to see the menu.


create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu		integer;

	-- Groups
	v_admin			integer;
BEGIN
	-- Get some group IDs
	select group_id into v_admin from groups where group_name = ''P/O Admins'';

	-- Determine the main menu. "Label" is used to
	-- identify menus.
	select menu_id into v_main_menu
	from im_menus where label=''admin'';

	-- Create the menu.
	v_menu := im_menu__new (
		null,				-- p_menu_id
		''acs_object'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-cvs-integration'',	-- package_name
		''cvs_integration'',		-- label
		''CVS Integration'',		-- name
		''/intranet-cvs-integration/'',	-- url
		259,				-- sort_order
		v_main_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_admin, ''read'');

	return 0;
end;' language 'plpgsql';
-- Execute and then drop the function
select inline_0 ();
drop function inline_0 ();




-----------------------------------------------------------
-- Plugin Components
--
-- Plugins are these grey boxes that appear in many pages in 
-- the system. This plugin shows the list of cvs commits per
-- ticket or project.


-- Create a Notes plugin for the ProjectViewPage.
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Project CVS Logs',		-- plugin_name
	'intranet-cvs-integration',	-- package_name
	'left',				-- location
	'/intranet/projects/view',	-- page_url
	null,				-- view_name
	140,				-- sort_order
	'im_cvs_log_component -object_id $project_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cvs-integration.Project_CVS_Logs "CVS Logs"'
where plugin_name = 'Project CVS Logs';



-- Create a Notes plugin for the TicketViewPage
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Ticket CVS Logs',		-- plugin_name
	'intranet-cvs-integration',	-- package_name
	'left',				-- location
	'/intranet-helpdesk/new',	-- page_url
	null,				-- view_name
	140,				-- sort_order
	'im_cvs_log_component -object_id $ticket_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cvs-integration.CVS_Logs "CVS Logs"'
where plugin_name = 'Ticket CVS Logs';




-- Create a Notes plugin for the TicketViewPage
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',			-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Conf Item CVS Logs',		-- plugin_name
	'intranet-cvs-integration',	-- package_name
	'left',				-- location
	'/intranet-confdb/new',		-- page_url
	null,				-- view_name
	140,				-- sort_order
	'im_cvs_log_component -conf_item_id $conf_item_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-cvs-integration.CVS_Logs "CVS Logs"'
where plugin_name = 'Conf Item CVS Logs';




----------------------------------------------------------------------
-- Permission component for Conf Items
----------------------------------------------------------------------

-- Create a Notes plugin for the TicketViewPage
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Conf Item CVS Permissions',	-- plugin_name
	'intranet-cvs-integration',	-- package_name
	'right',			-- location
	'/intranet-confdb/new',		-- page_url
	null,				-- view_name
	140,				-- sort_order
	'im_cvs_conf_item_permissions_component -conf_item_id $conf_item_id'	-- component_tcl
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Conf Item CVS Permissions'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


