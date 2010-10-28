<if @admin@>
	<form action="@perm_modify_url@" method="post">
	@perm_form_export_vars;noquote@
</if>
<if @read@>
	<listtemplate name="permissions"></listtemplate>
</if>
<if @admin@>
	<p>
	<input type="submit" value="#acs-subsite.Confirm#">
	</p>
	</form>
</if>

