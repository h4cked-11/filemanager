<%@ Page Language="C#" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Upload File</title>
</head>
<body>
    <form id="formUpload" runat="server" enctype="multipart/form-data">
        <div>
            <input type="file" id="fileUpload" runat="server" />
            <br />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
        </div>
    </form>

    <%
        if (IsPostBack)
        {
            if (Request.Files.Count > 0)
            {
                HttpPostedFile file = Request.Files[0];
                if (file != null && file.ContentLength > 0)
                {
                    try
                    {
                        string filename = Path.GetFileName(file.FileName);
                        string path = Server.MapPath("~/uploads/" + filename);
                        file.SaveAs(path);
                        Response.Write("Upload thành công!");
                    }
                    catch (Exception ex)
                    {
                        Response.Write("Lỗi: " + ex.Message);
                    }
                }
            }
        }
    %>
</body>
</html>
