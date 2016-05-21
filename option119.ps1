# Setting DNS Search Domains via DHCP for non-Windows clients

# The easiest way to check this is correct if you have a Mac client is to run
# `ipconfig [interface] | grep namelist` which will not only list your search
# list but also reports helpful errors such as 'name list missing end label'
# (not null terminated) or 'label length 108 > 63' (your segments are missing
# the length prefix)

# Note:
# Windows ignores this option, so for Windows clients this should  be set via
# group policy

# Format:
# Characters as bytes for each domain part segments prefixed by length,
# with each domain null terminated

$searchlist = "abc.example.com","def.example.com"
$encoding = [system.text.encoding]::utf8

$searchlistbytes = foreach ($domain in $searchlist) {
    foreach ($part in $domain -split '\.') {
        [byte]$part.length
        $encoding.getbytes($part)
    }
    [byte]0
}

add-dhcpserverv4optiondefinition 119 -name "DNS Search Domains" -type byte -multivalued
set-dhcpserverv4optionvalue 119 $searchlistbytes