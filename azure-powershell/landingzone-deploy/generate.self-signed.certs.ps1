#----------------------------
# Vars
#----------------------------
param (
    # TBD
)

#Create the root cert
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=WeuP2SRootCert" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My"  `
    -KeyUsageProperty Sign -KeyUsage CertSign 

# Create Client Cert
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
    -Subject "CN=WeuP2SClientCert1" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") 