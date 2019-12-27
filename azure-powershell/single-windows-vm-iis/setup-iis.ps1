# Install Websever Feature
Add-WindowsFeature Web-Server
# Create a default page
"Hi Visitor, this message is from Azure Windows VM: $($env:computername) !" | Out-File -FilePath "C:\inetpub\wwwroot\Default.htm"
# Further customization to be done later.
