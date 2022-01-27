Param
(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $SubscriptionName,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $SourceNSG,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $DestinationNSG
)

$csvFilePath = "$($home)\clouddrive\$SubscriptionName-nsg-rules.csv"
Set-AzContext -SubscriptionName $SubscriptionName | Out-Null

$azNsg = Get-AzNetworkSecurityGroup -Name $SourceNSG
$sourceNSGRuleConfig = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg




# Take care of the custom rules
Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
    @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
    @{label = 'Rule Name'; expression = { $_.Name } }, `
    @{label = 'Protocol Name'; expression = { $_.Protocol } }, `
    @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
    @{label = 'Source Application Security Group'; expression = { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } },
    @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
    @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
    @{label = 'Destination Application Security Group'; expression = { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } }, `
    @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
    @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
    Get-AzNetworkSecurityGroup -Name $DestinationNSG | `
    Add-AzNetworkSecurityRuleConfig -Name {$_.Name } -Protocol { $_.Protocol } -Access { $_.Access } `
        -Priority { $_.Priority } -Direction { $_.Direction } -SourceAddressPrefix { $_.SourceAddressPrefix } `
        -SourcePortRange  { $_.SourcePortRange } -DestinationAddressPrefix { $_.DestinationAddressPrefix } `
        -DestinationPortRange{ $_.DestinationPortRange }  -Verbose | `
    Set-AzNetworkSecurityGroup -Verbose |  `
    Export-Csv -Path $csvFilePath -NoTypeInformation -Append -force

# Take care of the default rules
Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg -Defaultrules | `
    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
    @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
    @{label = 'Rule Name'; expression = { $_.Name } }, `
    @{label = 'Protocol Name'; expression = { $_.Protocol} }, `
    @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
    @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
    @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
    @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
    @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
    Export-Csv -Path $csvFilePath -NoTypeInformation -Append -force