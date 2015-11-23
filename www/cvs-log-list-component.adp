  <form action="/intranet-cvs-integration/action" method=POST>
	<%= [export_vars -form {return_url}] %>
	<table class="table_list_page"> 
	  <thead>
	  <tr class="rowtitle">
	    <td>&nbsp;</td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Project "Repository"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Filename "Filename"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Revision "Rev"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Author "Author"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Add_Del "Add/Del"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_Note "Note"] %></td>
	    <td><%= [lang::message::lookup "" intranet-cvs-integration.Cvs_Logs_User "User"] %></td>
	  </tr>
	  </thead>
	  <tbody>
	  <multiple name="cvs_logs">
	    <if @cvs_logs.rownum@ odd><tr class="roweven"></if>
	    <else><tr class="rowodd"></else>
		<td><input type="checkbox" name="cvs_log.@cvs_line_id@"></td>
		<td>@cvs_logs.cvs_repo@</td>
		<td>@cvs_logs.cvs_filename@</td>
		<td>@cvs_logs.cvs_revision@</td>
		<td>@cvs_logs.cvs_author@</td>
		<td>+@cvs_logs.cvs_lines_add@/-@cvs_logs.cvs_lines_del@</td>
		<td>@cvs_logs.cvs_note@</td>
		<td>@cvs_logs.cvs_user@</td>
	    </tr>
	  </multiple>

<if @cvs_logs:rowcount@ eq 0>
	<tr class="rowodd">
	    <td colspan="2">
		<%= [lang::message::lookup "" intranet-cvs-integration.No_Cvs_Logs_Available "No Cvs_Logs Available"] %>
	    </td>
	</tr>
</if>
	</tbody>
	<tfoot>
	<tr class="rowodd">
	    <td colspan="2" align="right">
		<select name=action>
			<option value=del_cvs_logs><%= [lang::message::lookup "" intranet-cvs-integration.Delete_Cvs_Logs "Delete Cvs_Logs"] %></option>
		</select>	
		<input type="submit" value="Apply">
	    </td>
	</tr>
	</tfoot>
	</table>
	</form>	
