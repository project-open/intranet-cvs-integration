-- /packages/intranet-cvs-integration/sql/postgresql/intranet-cvs-integration-drop.sql
--
-- Copyright (c) 2003-2006 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com

drop sequence im_cvs_logs_seq;
drop table im_cvs_logs;

alter table persons drop column cvs_user;


alter table im_conf_items drop column cvs_repository;
alter table im_conf_items drop column cvs_protocol;
alter table im_conf_items drop column cvs_user;
alter table im_conf_items drop column cvs_password;
alter table im_conf_items drop column cvs_hostname;
alter table im_conf_items drop column cvs_port;
alter table im_conf_items drop column cvs_path;

SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_repository'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_protocol'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_user'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_password'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_hostname'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_port'
	)
));
SELECT im_dynfield_attribute__del((
       select attribute_id from im_dynfield_attributes where acs_attribute_id in (
       	      select attribute_id from acs_attributes where object_type = 'im_conf_item' and attribute_name = 'cvs_path'
	)
));


-- Delete any visibility of cvs_* fields
delete from im_dynfield_type_attribute_map
where attribute_id in (
	select	da.attribute_id
	from	im_dynfield_attributes da,
		acs_attributes aa
	where	da.acs_attribute_id = aa.attribute_id and
		aa.object_type = 'im_conf_item' and
		aa.attribute_name like 'cvs_%'
);



---------------------------------------------------------
-- delete potentially existing menus and plugins

select im_component_plugin__del_module('intranet-cvs-integration');
select im_menu__del_module('intranet-cvs-integration');



